require 'fileutils'
require 'colorize'
require 'active_support/core_ext/string'
require 'thor'
require 'bundler'

class Jets::Commands::Sequence < Thor::Group
  include Thor::Actions

  def self.source_root
    File.expand_path("new/templates/starter", File.dirname(__FILE__))
  end

private
  def copy_file(source, *args, &block)
    template(source, *args, &block)
  end
  public :copy_file # in order to override methods in Thor they have to first
    # be declared private

  def clone_project
    unless git_installed?
      abort "Unable to detect git installation on your system.  Git needs to be installed in order to use the --repo option."
    end

    if File.exist?(project_name)
      abort "The folder #{project_name} already exists."
    else
      run "git clone https://github.com/#{options[:repo]} #{project_name}"
    end
  end

  def copy_project
    puts "Creating new project called #{project_name}."
    directory ".", project_name
  end

  def git_installed?
    system("type git > /dev/null")
  end
end
