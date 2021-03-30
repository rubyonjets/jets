require 'fileutils'
require 'thor'
require 'bundler'

class Jets::Commands::Sequence < Thor::Group
  include Thor::Actions

  def self.source_root
    File.expand_path("templates/skeleton", File.dirname(__FILE__))
  end

private
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
    puts "Creating a new Jets project called #{@project_name}."
    directory ".", project_folder, copy_options
  end

  def copy_options
    excludes = case @options[:mode]
    when 'job'
      # For job mode: list of words to include in the exclude pattern and will not be generated.
      %w[
        Procfile
        controllers
        helpers
        javascript
        models/application_
        views
        config.ru
        database.yml
        dynamodb.yml
        routes
        db/
        spec
        yarn
        public
      ]
    when 'api'
      %w[
        views
      ]
    else # html
      []
    end

    unless @database
      # Do not even generate the config/database.yml because
      # Jets webpacker:install bombs and tries to load the db since it sees a
      # config/database.yml but there's no database pg gem configured.
      excludes += %w[
        database.yml
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
