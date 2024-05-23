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
        framework_app
      end
    end
    alias_method :app, :rack_app
    alias_method :app=, :rack_app=

    def framework_app
      # Explicitly set boot_path takes precedence
      # IE: my_app.rb => MyApp
      if @boot_path && File.exist?(@boot_path)
        app_class = @boot_path.sub(/\.rb$/, "").camelize.constantize
        return app_class
      end

      # Infer app.rb boot_path
      # IE: app.rb => App
      if File.exist?("app.rb")
        require_boot_path("app")
        return App
      end

      # Infer rack app from config.ru
      case framework
      when "rails"
        require_boot_path "config/environment"
        Rails.application
      when "hanami"
        require "hanami/boot"
        Hanami.app
      end
    end

    def require_boot_path(path)
      path = path.starts_with?(".") ? path : "./#{path}"
      path = path.ends_with?(".rb") ? path : "#{path}.rb"
      require path # IE: config/environment.rb (Rails) or app.rb (generic rack app)
    end

    def framework
      Jets::Framework.name
    end
  end
end
