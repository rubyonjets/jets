module Jets::Git
  class Gitlab < Base
    def info
      info = {
        git_system: "gitlab",
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
      ENV["CI_COMMIT_REF_NAME"]
    end

    def git_sha
      ENV["CI_COMMIT_SHA"]
    end

    def git_url
      host = ENV["CI_SERVER_URL"] || "https://gitlab.com"
      full_repo = ENV["CI_PROJECT_PATH"]
      "#{host}/#{full_repo}"
    end
  end
end
