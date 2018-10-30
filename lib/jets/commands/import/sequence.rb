require 'fileutils'
require 'colorize'
require 'active_support/core_ext/string'
require 'thor'
require 'bundler'

class Jets::Commands::Import::Sequence < Thor::Group
  include Thor::Actions
  argument :source

private
  def clone_project
    check_git_installed

    command = "git clone #{repo_url} #{rack_folder}"
    puts "=> #{command}"
    if File.exist?(rack_folder)
      abort "The folder #{rack_folder} already exists."
    else
      run command
    end
  end

  def copy_project
    puts "Creating rack folder"
    template_path = File.expand_path(@source)
    set_source_paths(template_path)
    directory ".", rack_folder
  end

  def set_source_paths(*paths)
    # Using string with instance_eval because block doesnt have access to
    # path at runtime.
    self.class.instance_eval %{
      def self.source_paths
        #{paths.flatten.inspect}
      end
    }
  end

  # normalize repo_url
  def repo_url
    if @source.include?('github.com')
      @source # leave as is, user has provided full github url
    else
      "https://github.com/#{@source}"
    end
  end

  def repo?
    @source.include?('github.com')
  end

  def check_git_installed
    return unless repo_url.include?('http') || repo_url.include?('git@')
    unless git_installed?
      abort "Unable to detect git installation on your system.  Git needs to be installed in order to clone the project."
    end
  end

  def git_installed?
    system("type git > /dev/null 2>&1")
  end

  def rack_folder
    "#{Jets.root}rack"
  end
end