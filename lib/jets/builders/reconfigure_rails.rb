# TODO: Move logic into plugin instead
class Jets::Builders
  class ReconfigureRails
    def initialize(full_app_root)
      # IE: @app_root: /tmp/jets/demo/stage/code/rack
      @app_root = full_app_root
    end

    # Only support for rails right now. Move into plugin if when adding support to
    # more frameworks.
    def run
      return unless rails?

      puts "Reconfiguring rails app"
      templates = File.expand_path("./after_rack_package/rails", File.dirname(__FILE__))

      relative_path = "config/initializers/jets.rb"
      src = "#{templates}/#{relative_path}"
      dest = "#{@app_root}/#{relative_path}"
      FileUtils.mkdir_p(File.dirname(dest))
      FileUtils.cp(src, dest)
    end

    # Rudimentary rails detection
    def rails?
      config_ru = "#{@app_root}/config.ru"
      return false unless File.exist?(config_ru)
      !IO.readlines(config_ru).grep(/Rails.application/).empty?
    end
  end
end
