module Jets::Git
  module GitCli
    def git?
      git_folder? && git_installed? && git_commits?
    end

    def git_folder?
      File.exist?(".git")
    end

    def git_installed?
      system "type git > /dev/null 2>&1"
    end

    # Edge case: git init but no commits yet
    def git_commits?
      system "git rev-parse HEAD >/dev/null 2>&1"
    end

    def git(args, on_error: :nil)
      out = `git #{args}`.strip
      unless $?.success?
        case on_error
        when :raise
          raise Jets::Git::Error, "ERROR: git #{args} failed".color(:red)
        when :nil
          return
        end
      end
      out
    end
  end
end
