module Jets::Generators::Overrides::App
  module Helpers
  private
    def set_initial_variables
      @project_folder = app_path
      @project_name = app_path == '.' ? File.basename(Dir.pwd) : app_path
      @app_namespace = @project_name.gsub('-','_').gsub(/[^a-zA-Z_0-9]/, '').camelize
      @database_name = @project_name.gsub('-','_')

      # options is a frozen hash by Thor so cannot modify it.
      # Also had trouble unfreezing it with .dup. So using instance variables instead
      case options[:mode]
      when 'html'
        @bootstrap = options[:bootstrap]
        @database = options[:database]
        @javascript = options[:javascript] # importmap or webpacker
      when 'api'
        @bootstrap = false
        @database = options[:database]
        @javascript = 'none'
      when 'job'
        @bootstrap = false
        @database = false
        @javascript = 'none'
      else
        puts "Invalid mode provided: #{@options[:mode].color(:red)}. Please pass in an valid mode: #{VALID_MODES.join(',').color(:green)}."
        exit 1
      end
    end

    def jets_minor_version
      md = Jets::VERSION.match(/(\d+)\.(\d+)\.\d+/)
      major, minor = md[1], md[2]
      [major, minor, '0'].join('.')
    end

    def clone_project
      unless git_installed?
        abort "Unable to detect git installation on your system. Git needs to be installed in order to use the --repo option."
      end

      if File.exist?(project_folder)
        abort "The folder #{project_folder} already exists."
      else
        run "git clone https://github.com/#{options[:repo]} #{project_folder}"
      end
      confirm_jets_project
    end

    def confirm_jets_project
      jets_project = File.exist?("#{project_folder}/config/application.rb")
      unless jets_project
        puts "#{options[:repo]} does not look like a Jets project. Double check your repo!".color(:red)
        exit 1
      end
    end

    def copy_project
      directory ".", ".", copy_options
    end

    def copy_options
      excludes = excludes()
      default_excludes = %w[
        bin
      ]
      excludes += default_excludes
      excludes.uniq!

      unless @database
        excludes += %w[
          database.yml
          db
          models/application_record
        ]
      end

      if excludes.empty?
        {}
      else
        pattern = Regexp.new(excludes.join('|'))
        {exclude_pattern: pattern }
      end
    end

    def excludes
      case @options[:mode]
      when 'job'
        # For job mode: list of words to include in the exclude pattern and will not be generated.
        %w[
          app/views
          assets
          config.ru
          config/database.yml
          config/dynamodb.yml
          config/initializers
          controllers
          db/
          helpers
          javascript
          models/application_
          Procfile
          public
          routes
          spec
          yarn
        ]
      when 'api'
        %w[
          app/assets
          app/views
        ]
      else # html
        []
      end
    end

    def git_first_commit
      return unless git_installed? && git_credentials_set?
      run("git add .")
      run("git commit -m 'first commit'")
    end

    def git_installed?
      system("type git > /dev/null 2>&1")
    end

    # In order to automatically create first commit
    # the user needs to have their credentials set
    def git_credentials_set?
      configs = `git config --list`.split("\n")
      configs.any? { |c| c.start_with? 'user.name=' } && configs.any? { |c| c.start_with? 'user.email=' }
    end

    def yarn_installed?
      system("type yarn > /dev/null 2>&1")
    end
  end
end
