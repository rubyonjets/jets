require 'fileutils'

class Jets::Commands::Upgrade
  class V1
    def initialize(options)
      @options = options
    end

    def run
      puts "Upgrading to Jets v1..."
      environment_configs
      update_routes
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

      puts "Update: config/routes.rb"
      lines = IO.readlines(routes_file)
      lines.map! do |line|
        if line.include?('root "jets/welcome#index"')
          %Q|  root "jets/public#show"\n| # assume 2 spaces for simplicity
        else
          line
        end
      end

      content = lines.join
      IO.write(routes_file, content)
    end
  end
end
