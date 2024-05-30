module Jets::Git
  class Local < Base
    include GitCli

    def info
      return {} unless git? && git_branch
      info = {
        git_system: "local",
        git_branch: git_branch,
        git_sha: git_sha,
        git_dirty: git_dirty?,
        git_message: git_message,
        git_version: git_version,
        git_default_branch: git_default_branch
      }
      info[:git_url] = git_url if git_url
      info
    end

    def git_message
      git "log -1 --pretty=%B"
    end

    def git_branch
      git "rev-parse --abbrev-ref HEAD"
    end

    def git_sha
      git "rev-parse HEAD"
    end

    def git_url
      # IE: git "config --get remote.origin.url"
      git "config --get remote.#{git_remote}.url"
    end

    def git_dirty?
      !git("status --porcelain").empty?
    end

    def git_version
      git "--version", on_error: :raise
    end

    # discover git remote name. in case it's not origin
    def git_remote
      # 2>&1 to suppress error message
      #   "fatal: not a git repository (or any parent up to mount point /path)\nStopping at filesystem boundary (GIT_DISCOVERY_ACROSS_FILESYSTEM not set).\n"
      `git remote 2>&1`
      return unless $?.success?
      `git remote`.strip # IE: origin or blank string
    end
    memoize :git_remote

    def git_default_branch
      default = ENV["JETS_GIT_DEFAULT_BRANCH"] || "master"
      out = `git remote show origin 2>&1`.strip
      return default unless $?.success?

      lines = out.split("\n")
      lines.each do |line|
        if line.include?("HEAD")
          return line.split(" ").last
        end
      end
      default
    end

    def git_current_branch
      `git rev-parse --abbrev-ref HEAD`.strip
    end
  end
end
