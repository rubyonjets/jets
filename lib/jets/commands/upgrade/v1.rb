require 'fileutils'

# This class tries to be idempotent, so users should be able to run it multiple times safely.
class Jets::Commands::Upgrade
  class V1
    def initialize(options)
      @options = options
    end

    def run
      puts "Upgrading to Jets v1..."
      environment_configs
      update_routes
      update_mode_setting
      update_config_ru
      puts "Upgrade complete."
    end

    def environment_configs
      path = File.expand_path("../templates/skeleton/config/environments", File.dirname(__FILE__))
      Dir.glob("#{path}/*").each do |src|
        config_file = "config/environments/#{File.basename(src)}"
        dest = "#{Jets.root}#{config_file}"
        unless File.exist?(dest)
          puts "Create: #{config_file}"
          FileUtils.mkdir_p(File.dirname(dest))
          FileUtils.cp(src, dest)
        end
      end
    end

    def update_routes
      routes_file = "#{Jets.root}config/routes.rb"
      return unless File.exist?(routes_file)

      lines = IO.readlines(routes_file)
      deprecated_code = 'root "jets/welcome#index"'
      return unless lines.detect { |l| l.include?(deprecated_code) }

      puts "Update: config/routes.rb"
      lines.map! do |line|
        if line.include?(deprecated_code)
          %Q|  root "jets/public#show"\n| # assume 2 spaces for simplicity
        else
          line
        end
      end

      content = lines.join
      IO.write(routes_file, content)
    end

    def update_mode_setting
      application_file = "#{Jets.root}config/application.rb"
      lines = IO.readlines(application_file)
      deprecated_code = 'config.api_generator'
      return unless lines.detect { |l| l.include?(deprecated_code) }

      puts "Update: config/application.rb"
      lines.map! do |line|
        if line.include?(deprecated_code)
          mode = Jets.config.api_generator ? 'api' : 'html'
          %Q|  config.mode = "#{mode}"\n| # assume 2 spaces for simplicity
        else
          line
        end
      end

      content = lines.join
      IO.write(application_file, content)
    end

    def update_config_ru
      config_ru = File.read("#{Jets.root}config.ru")
      return if config_ru.include?("Jets.boot")

      src = File.expand_path("../templates/skeleton/config.ru", File.dirname(__FILE__))
      dest = "#{Jets.root}config.ru"
      puts "Update: config.ru"
      FileUtils.cp(src, dest)
    end
  end
end
