require 'fileutils'

# This class tries to be idempotent, so users should be able to run it multiple times safely.
module Jets::Commands
  class Upgrade
    def initialize(options)
      @options = options
    end

    def run
      puts "Upgrading to Jets structure to latest version"
      environment_configs
      update_routes
      update_mode_setting
      update_config_ru
      remove_ruby_lazy_load
      update_webpack_binstubs
      add_dynomite_to_gemfile
      puts "Upgrade complete."
    end

    def environment_configs
      path = File.expand_path("templates/skeleton/config/environments", File.dirname(__FILE__))
      puts "path #{path}"
      Dir.glob("#{path}/*").each do |src|
        config_file = "config/environments/#{File.basename(src)}"
        dest = "#{Jets.root}#{config_file}"

        puts "src #{src}"
        puts "dest #{dest}"
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

      src = File.expand_path("templates/skeleton/config.ru", File.dirname(__FILE__))
      dest = "#{Jets.root}config.ru"
      puts "Update: config.ru"
      FileUtils.cp(src, dest)
    end

    def remove_ruby_lazy_load
      app_config = "#{Jets.root}config/application.rb"
      remove_ruby_lazy_load_for(app_config)
      Dir.glob("#{Jets.root}config/environments/*.rb").each do |env_config|
        remove_ruby_lazy_load_for(env_config)
      end
    end

    def remove_ruby_lazy_load_for(path)
      lines = IO.readlines(path)
      new_lines = lines.reject do |l|
        l =~ %r{config.ruby.lazy_load}
      end
      return unless lines != new_lines

      content = new_lines.join("")
      IO.write(path, content)
      puts "Update: #{path}"
    end

    def update_webpack_binstubs
      lines = IO.readlines("bin/webpack")
      already_upgraded = lines.detect { |l| l =~ /WebpackRunner/ }
      return if already_upgraded

      update_project_file("bin/webpack")
      update_project_file("bin/webpack-dev-server")
      puts "Updated webpack binstubs."
    end

    def add_dynomite_to_gemfile
      return unless File.exist?("app/models/application_item.rb")

      lines = IO.readlines("Gemfile")
      dynomite_found = lines.detect { |l| l =~ /dynomite/ }
      return if dynomite_found

      File.open('Gemfile', 'a') do |f|
        f.puts 'gem "dynomite"'
      end
      puts "Updated Gemfile: add dynomite gem"
    end

  private
    def update_project_file(relative_path)
      templates = File.expand_path("upgrade/templates", File.dirname(__FILE__))
      src = "#{templates}/#{relative_path}"
      dest = relative_path
      FileUtils.mkdir_p(File.dirname(dest))
      FileUtils.cp(src, dest)
      puts "Update: #{dest}"
    end
  end
end
