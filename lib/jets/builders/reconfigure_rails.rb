# TODO: Move logic into plugin instead
module Jets::Builders
  class ReconfigureRails
    def initialize(full_app_root)
      # IE: @app_root: /tmp/jets/demo/stage/code/rack
      @app_root = full_app_root
    end

    # Only support Rails right now. Maybe move into plugin when adding support
    # to more frameworks. Or maybe better to just abstract but maintain in Jets.
    def run
      return unless rails?

      puts "Mega Mode: Reconfiguring Rails app."
      copy_initializer
      update_gemfile
      update_development_environment
      set_favicon
    end

    def copy_initializer
      templates = File.expand_path("./reconfigure_rails", File.dirname(__FILE__))
      relative_path = "config/initializers/jets.rb"
      src = "#{templates}/#{relative_path}"
      result = Jets::Erb.result(src, api_mode: rails_api?)
      dest = "#{@app_root}/#{relative_path}"
      FileUtils.mkdir_p(File.dirname(dest))
      IO.write(dest, result)
    end

    def api_mode?
    end

    def update_gemfile
      gemfile = "#{@app_root}/Gemfile"
      lines = IO.readlines(gemfile)
      lines = add_jets_rails_gem(lines)
      lines = comment_out_ruby_declaration(lines)
      write_content(gemfile, lines)
    end

    def add_jets_rails_gem(lines)
      return lines if lines.detect { |l| l =~ /jets-rails/ }
      lines << "\n"
      lines << %Q|gem "jets-rails"\n|
      lines
    end

    # Jets packages up and uses only one version of ruby and different declarations
    # of ruby can cause issues.
    def comment_out_ruby_declaration(lines)
      lines.map do |l|
        l =~ /^(ruby[ (].*)/ ? "# #{$1} # commented out by jets" : l
      end
    end

    def update_development_environment
      env_file = "#{@app_root}/config/environments/development.rb"
      lines = IO.readlines(env_file)
      new_lines = lines.map do |line|
        if line =~ /(config\.file_watcher.*)/
          "  # #{$1} # commented out by jets\n"
        else
          line
        end
      end
      write_content(env_file, new_lines)
    end

    # Evaluate the application layout and see if has a custom favicon defined yet.
    # If not insert one and rewrite the application layout.
    #
    # This avoids serving binary assets from API gateway, instead serve it from s3 directly.
    def set_favicon
      app_layout = "#{@app_root}/app/views/layouts/application.html.erb"
      return  unless File.exist?(app_layout)

      favicon = '<link rel="shortcut icon" href="<%= asset_path("/favicon.ico") %>">'

      lines = IO.readlines(app_layout)
      has_favicon = !!lines.find { |l| l.include?(favicon) }
      return if has_favicon

      content = IO.read(app_layout)
      content = content.sub('</head>', "\n    #{favicon}\n  </head>")

      IO.write(app_layout, content)
    end

    # lines is an Array
    def write_content(path, lines)
      content = lines.join + "\n"
      IO.write(path, content)
    end

    # Rudimentary rails detection
    # Duplicated in builders/code_builders.rb
    def rails?
      config_ru = "#{@app_root}/config.ru"
      return false unless File.exist?(config_ru)
      !IO.readlines(config_ru).grep(/Rails.application/).empty?
    end

    # Rudimentary rails api detection
    # Duplicated in builders/code_builders.rb
    # Another way of checking is loading a rails console and checking Rails.application.config.api_only
    # Using this way for simplicity.
    def rails_api?
      config_app = "#{@app_root}/config/application.rb"
      return false unless File.exist?(config_app)
      !IO.readlines(config_app).grep(/config.api_only.*=.*true/).empty?
    end
  end
end
