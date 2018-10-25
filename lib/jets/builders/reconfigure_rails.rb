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
      copy_initializer
      update_gemfile
      update_development_environment
    end

    def copy_initializer
      templates = File.expand_path("./reconfigure_rails", File.dirname(__FILE__))
      relative_path = "config/initializers/jets.rb"
      src = "#{templates}/#{relative_path}"
      dest = "#{@app_root}/#{relative_path}"
      FileUtils.mkdir_p(File.dirname(dest))
      FileUtils.cp(src, dest)
    end

    def update_gemfile
      gemfile = "#{@app_root}/Gemfile"
      lines = IO.readlines(gemfile)
      return if lines.detect { |l| l =~ /jets-rails/ }

      # Add jets-rails gem
      lines << "\n"
      lines << %Q|gem "jets-rails", git: "https://github.com/tongueroo/jets-rails.git"\n|
      write_content(gemfile, lines)
    end

    def update_development_environment
      env_file = "#{@app_root}/config/environments/development.rb"
      lines = IO.readlines(env_file)
      new_lines = lines.map do |line|
        if line =~ /(config\.file_watcher.*)/
          "  # #{$1}"
        else
          line
        end
      end
      write_content(env_file, new_lines)
    end

    # lines is an Array
    def write_content(path, lines)
      content = lines.join + "\n"
      IO.write(path, content)
    end

    # Rudimentary rails detection
    def rails?
      config_ru = "#{@app_root}/config.ru"
      return false unless File.exist?(config_ru)
      !IO.readlines(config_ru).grep(/Rails.application/).empty?
    end
  end
end
