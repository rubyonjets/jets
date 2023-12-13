require "singleton"

module Jets::Shim
  class Config
    extend Memoist
    include Singleton

    attr_reader :boot_path
    attr_accessor :fallback_handler, :adapter
    attr_writer :rack_app

    def boot_path=(value)
      @boot_path = value # dont include ./ in @boot_path. @boot_path can be used to infer the rack_app class name
      # Immediately require the boot_path so that rack_app is available for reference
      require_boot_path(value)
    end

    def rack_app
      if Maintenance.enabled?
        Maintenance.app
      elsif @rack_app
        @rack_app
      else
        boot_path = @boot_path || infer_boot_path
        # Possible that boot_path is nil.
        # Case: Jets events app only.
        if boot_path
          require_boot_path(boot_path) if boot_path # in case boot_path is not set
          infer_rack_app(boot_path) # IE: Rails.application or App
        end
      end
    end
    alias_method :app, :rack_app
    alias_method :app=, :rack_app=

    def infer_boot_path
      if rails?
        "config/environment"
      elsif File.exist?("app.rb")
        "app"
      end
    end

    def require_boot_path(path)
      path = path.starts_with?(".") ? path : "./#{path}"
      path = path.ends_with?(".rb") ? path : "#{path}.rb"
      require path # IE: config/environment.rb (Rails) or app.rb (generic rack app)
    end

    def infer_rack_app(boot_path)
      if rails?
        Rails.application
      else
        boot_path.sub!(/\.rb$/, "") # remove .rb extension
        boot_path.camelize.constantize
      end
    end

    def rails?
      framework?(:rails)
    end

    def framework?(name)
      if File.exist?("config.ru")
        # IE: Jets.application or Rails.application
        IO.readlines("config.ru").any? { |l| l.include?("#{name.to_s.camelize}.application") }
      end
    end
    memoize :framework?
  end
end
