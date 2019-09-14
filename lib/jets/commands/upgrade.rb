require 'fileutils'

# This class tries to be idempotent, so users should be able to run it multiple times safely.
module Jets::Commands
  class Upgrade
    def initialize(options)
      @options = options
    end

    def run
      puts "Upgrading to Jets structure to latest version"
      Version1.new.run
      # version 2 upgrades
      inject_csrf_meta_tags
      update_crud_js
      update_config_application_rb
      update_autoload_paths_config
      puts "Upgrade complete."
    end

    def inject_csrf_meta_tags
      layout = "app/views/layouts/application.html.erb"
      return unless File.exist?(layout)

      lines = IO.readlines(layout)
      csrf_meta_tags = lines.find { |l| l =~ /<%= csrf_meta_tags %>/ }
      return if csrf_meta_tags

      puts "Update: #{layout} with csrf_meta_tags helper"
      lines.map! do |line|
        if line.include?("<head>")
          # add csrf_meta_tags helper
          "#{line}  <%= csrf_meta_tags %>\n"
        else
          line
        end
      end

      content = lines.join
      IO.write(layout, content)
    end

    def update_crud_js
      src = File.expand_path("templates/webpacker/app/javascript/src/jets/crud.js", File.dirname(__FILE__))
      dest = "app/javascript/src/jets/crud.js"
      return unless File.exist?(dest)

      lines = IO.readlines(dest)
      csrf = lines.find { |l| l =~ /csrf-token/ }
      return if csrf

      FileUtils.mkdir_p(File.dirname(dest))
      FileUtils.cp(src, dest)
      puts "Update: #{dest}"
    end

    def update_config_application_rb
      app_rb = "config/application.rb"
      lines = IO.readlines(app_rb)
      api_mode = lines.find { |l| l =~ /config\.mode/ && l =~ /api/ }
      return unless api_mode

      forgery = lines.find { |l| l =~ /default_protect_from_forgery/ }
      return if forgery

      lines.map! do |line|
        if line =~ /^end/
          # add default_protect_from_forgery = false
          "  config.controllers.default_protect_from_forgery = false\n#{line}"
        else
          line
        end
      end

      content = lines.join
      IO.write(app_rb, content)
      puts "Update: #{app_rb} with default_protect_from_forgery"
    end

    def update_autoload_paths_config
      app_rb = "config/application.rb"
      lines = IO.readlines(app_rb)

      new_config = lines.find { |l| l.include?('config.autoload_paths') }
      return if new_config

      old_config = lines.find { |l| l.include?('config.extra_autoload_paths') }
      return unless old_config

      lines.map! do |line|
        md = line.match(/config\.extra_autoload_paths(.*)/)
        if md
          rest = md[1]
          "  config.autoload_paths#{rest}"
        else
          line
        end
      end

      content = lines.join
      IO.write(app_rb, content)
      puts "Update: #{app_rb} with config.autoload_paths"
    end
  end
end
