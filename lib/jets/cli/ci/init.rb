class Jets::CLI::Ci
  class Init < Jets::CLI::Group::Base
    include Jets::Util::Sure

    def self.cli_options
      [
        [:force, aliases: :f, type: :boolean, desc: "Bypass overwrite are you sure prompt for existing files"],
        [:yes, aliases: :y, type: :boolean, desc: "Skip are you sure prompt"]
      ]
    end
    cli_options.each { |args| class_option(*args) }

    source_root "#{__dir__}/templates"

    private

    def sure_message
      <<~EOL
        This will set up some initial Jets CI project settings.

        It will make changes to your project source code.

        Please make sure you have backed up and committed your changes first.
      EOL
    end

    def git_info
      @git_info ||= Jets::Git::Info.new
    end

    def git_default_branch
      git_info.params[:git_default_branch] || "master"
    end

    def repo_location
      git_url = git_info.params[:git_url] || "https://github.com/ORG/REPO"
      if git_url.starts_with?("git@")
        git_url.sub(":", "/").sub("git@", "https://").sub(".git", "")
      else
        git_url
      end
    end

    def repo_type
      case repo_location
      when /github/
        "GITHUB"
      when /gitlab/
        "GITLAB"
      when /bitbucket/
        "BITBUCKET"
      when /codecommit/
        "CODECOMMIT"
      else
        "REPLACE_ME"
      end
    end

    public

    def check_jets_initialized
      unless File.exist?("config/jets/deploy.rb")
        puts "config/jets/deploy.rb not found."
        puts "Please run: jets init"
        exit 1
      end
    end

    def check_already_initialized
      if File.exist?("config/jets/ci.rb")
        puts "Found config/jets/ci.rb"
        puts "It looks like the Jets project is already initialized for CI"
        exit
      end

      lines = IO.readlines("config/jets/deploy.rb")
      found = lines.detect do |l|
        l.include?("config.deploy.") && !l.match?(/^\s*#/)
      end
      if found
        puts "Found config.ci in config/jets/deploy.rb"
        puts "It looks like the Jets project has already been set up for CI"
        exit
      end
    end

    def are_you_sure?
      return if options[:yes]
      sure?(sure_message)
    end

    # https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-properties-codebuild-project-source.html#cfn-codebuild-project-source-type
    def config_jets_ci
      template "ci.rb.tt", "config/jets/ci.rb"
    end
  end
end
