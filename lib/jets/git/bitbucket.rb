module Jets::Git
  class Bitbucket < Base
    def info
      info = {
        git_system: "bitbucket",
        git_branch: git_branch,
        git_sha: git_sha,
        git_dirty: false
        # git_message: nil,
        # git_version: nil,
      }
      info[:git_url] = git_url if git_url
      info
    end

    def git_branch
      ENV["BITBUCKET_BRANCH"]
    end

    def git_sha
      ENV["BITBUCKET_COMMIT"]
    end

    def git_url
      host = ENV["BITBUCKET_HOST"] || "https://bitbucket.org"
      full_repo = ENV["BITBUCKET_REPO_FULL_NAME"]
      "#{host}/#{full_repo}"
    end
  end
end
