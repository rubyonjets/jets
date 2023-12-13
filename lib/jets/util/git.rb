module Jets::Util
  module Git
    def git?
      File.exist?("#{Jets.root}/.git") && git_installed?
    end

    def git_installed?
      system("type git > /dev/null 2>&1")
    end
  end
end
