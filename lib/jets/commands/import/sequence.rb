require 'bundler'
require 'fileutils'
require 'thor'

class Jets::Commands::Import
  class Sequence < Thor::Group
    include Thor::Actions
    argument :source

  private
    def clone_project
      if File.exist?(rack_folder)
        abort "The folder #{rack_folder} already exists.  Please remove it first if you want to import a project."
      end

      check_git_installed
      if @options[:submodule]
        git_submodule
      else
        git_clone
      end
    end

    def git_submodule
      puts "Adding project as a submodule"
      run "git submodule add --force #{repo_url} #{rack_folder}"
      Cheatsheet.create(repo_url)
    end

    def git_clone
      command = "git clone #{repo_url} #{rack_folder}"
      # Thor's run already puts out the command, so no need to puts
      run command
      run "rm -rf #{Jets.root}rack/.git"
    end

    def copy_project
      puts "Creating rack folder"
      template_path = File.expand_path(@source)
      set_source_paths(template_path)
      begin
        directory ".", rack_folder, exclude_pattern: %r{.git}
      rescue Thor::Error => e
        puts e.message.color(:red)
        exit 1
      end
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
      if repo?
        @source # leave as is, user has provided full github url
      else
        # Defaults to GitHub
        "https://github.com/#{@source}"
      end
    end

    def repo?
      @source.include?('github.com') ||
      @source.include?('bitbucket.org') ||
      @source.include?('gitlab.com')
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
      "#{Jets.root}/rack"
    end
  end
end