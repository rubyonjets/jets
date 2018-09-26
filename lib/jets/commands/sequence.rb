require 'fileutils'
require 'colorize'
require 'active_support/core_ext/string'
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

    if File.exist?(project_name)
      abort "The folder #{project_name} already exists."
    else
      run "git clone https://github.com/#{options[:repo]} #{project_name}"
    end
    confirm_jets_project
  end

  def confirm_jets_project
    jets_project = File.exist?("#{project_name}/config/application.rb")
    unless jets_project
      puts "It does not look like the repo #{options[:repo]} is a jets project. Maybe double check that it is?  Exited.".colorize(:red)
      exit 1
    end
  end

  def copy_project

    puts "Creating new project called #{project_name}."

    directory ".", project_name, copy_options
  end

  def copy_options
    # list of words to include in the exclude pattern and will not be generated
    words = %w[
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

    if @options[:mode] == 'job'
      { exclude_pattern: Regexp.new(words.join('|')) }
    else
      {}
    end
  end

  def git_installed?
    system("type git > /dev/null")
  end
end
