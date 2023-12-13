module Jets::Git
  module GitCli
    def git?
      git_folder? && git_installed?
    end

    def git_folder?
      File.exist?(".git")
    end

    def git_installed?
      system "type git > /dev/null 2>&1"
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
