require 'fileutils'
require 'colorize'
require 'thor'
require 'bundler'

class Jets::Commands::Sequence < Thor::Group
  include Thor::Actions

  def self.source_root
    File.expand_path("templates/skeleton", File.dirname(__FILE__))
  end

private
  def clone_project
    unless git_installed?
      abort "Unable to detect git installation on your system.  Git needs to be installed in order to use the --repo option."
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
      puts "It does not look like the repo #{options[:repo]} is a jets project. Maybe double check that it is?  Exited.".colorize(:red)
      exit 1
    end
  end

  def copy_project
    puts "Creating new project called #{@project_name}."
    directory ".", project_folder, copy_options
  end

  def copy_options
    excludes = if @options[:mode] == 'job'
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
    elsif !@database
      # Do not even generated the config/database.yml because
      # jets webpacker:install bombs and tries to load the db since it sees a
      # config/database.yml but has there's no database pg gem configured.
      %w[
        database.yml
        models/application_record
      ]
    else
      []
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
