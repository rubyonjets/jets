require "open3"

class Jets::CLI
  class Git < Jets::CLI::Base
    def initialize(options = {})
      super
      @args = options[:args] || []
      @command = @args[0]
    end

    def run
      if @command == "push" && Jets::Thor::ProjectCheck.new(@args).project?
        git_push
        jets_ci_logs
      else
        # pass through to git command
        Kernel.exec(git_bin, *@args)
      end
    end

    def git_push
      puts "=> git #{@args.join(" ")}"

      IO.popen([git_bin, *@args]) do |io|
        io.each do |line|
          puts line
        end
      end

      exit $?.exitstatus unless $?.success?
    end

    def jets_ci_logs
      return unless show_logs?
      command = [env_vars, "jets ci:logs"].compact.join(" ")
      Kernel.exec(command)
    end

    def show_logs?
      File.exist?("config/jets/ci.rb") &&
        Jets.project.config.git.push.branch[push_branch].present?
    end

    def env_vars
      env_vars = Jets.project.config.git.push.branch[push_branch]
      return unless env_vars
      # IE: branch_name = {JETS_ENV: "xxx", AWS_PROFILE: "xxx"}
      env_vars.map do |k, v|
        "#{k}=#{v}"
      end.sort.join(" ")
    end

    # man git-push
    # git push
    # git push origin
    # git push origin :
    # git push origin master
    # git push origin HEAD
    # git push mothership master:satellite/master dev:satellite/dev
    # git push origin HEAD:master
    # git push origin master:refs/heads/experimental
    # git push origin :experimental
    # git push origin +dev:master
    def push_branch
      args = @args.reject { |arg| arg.start_with?("-") } # remove options
      case args.size
      when 1 # git push
        local.git_default_branch
      when 2 # git push origin
        local.git_current_branch
      when 3 # git push origin master
        args.last
      else
        raise "ERROR: Too many arguments. Usage: jets git:push [REMOTE] [BRANCH]"
      end
    end

    def local
      Jets::Git::Local.new
    end
    memoize :local

    def git_bin
      "/usr/bin/git"
    end
  end
end
