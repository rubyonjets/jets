module Jets::Git
  class Custom < Base
    def info
      info = {
        git_system: "custom",
        git_branch: git_branch,
        git_sha: git_sha,
        git_dirty: false,
        git_message: git_message
        # git_version: nil,
      }
      info[:git_url] = git_url if git_url
      info
    end

    def git_branch
      ENV["JETS_GIT_CUSTOM_BRANCH"]
    end

    def git_sha
      ENV["JETS_GIT_CUSTOM_SHA"]
    end

    def git_url
      ENV["JETS_GIT_CUSTOM_URL"]
    end

    def git_message
      ENV["JETS_GIT_CUSTOM_MESSAGE"]
    end
  end
end
