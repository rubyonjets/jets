module Jets::Cfn::Builders::Util
  class Source
    class << self
      def version
        return '' unless git_installed?
        sha = sh "git rev-parse HEAD 2>/dev/null"
        return '' if sha == ''  # if its not a git repo, it'll be an empty string
        sha[0..7]
      end

    private
      def git_installed?
        system("type git > /dev/null 2>&1")
      end

      def sh(command)
        `#{command}`.strip
      end
    end
  end
end
