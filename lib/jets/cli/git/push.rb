require "open3"

class Jets::CLI::Git
  class Push < Jets::CLI::Base
    def initialize(options = {})
      super
      @args = options[:args] || []
    end

    def run
      args = ["push"] + @args
      puts "=> git #{args.join(" ")}"

      IO.popen(["git", *args]) do |io|
        io.each do |line|
          puts line
        end
      end

      return unless $?.success?

      set_env_vars!
      sleep 2 # wait ci to start
      Jets::CLI::Ci::Logs.new(options).run
    end

    def set_env_vars!
      env_vars = Jets.project.config.git.push.branch[push_branch] || {}
      # IE: branch_name = {JETS_ENV: "xxx", AWS_PROFILE: "xxx"}
      env_vars.each do |k, v|
        ENV[k.to_s] = v
      end
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
      when 0
        local.git_default_branch
      when 1
        local.git_current_branch
      when 2
        args.last
      else
        raise "ERROR: Too many arguments. Usage: jets git:push [REMOTE] [BRANCH]"
      end
    end

    def local
      Jets::Git::Local.new
    end
    memoize :local
  end
end
