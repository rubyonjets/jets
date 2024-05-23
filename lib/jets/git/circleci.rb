module Jets::Git
  class Circleci < Base
    def info
      {
        git_system: "circleci",
        git_branch: git_branch,
        git_sha: git_sha,
        git_dirty: false
        # git_message: nil,
        # git_version: nil,
      }
      # info[:git_url] = git_url if git_url
    end

    def git_branch
      ENV["CIRCLE_BRANCH"]
    end

    def git_sha
      ENV["CIRCLE_SHA1"]
    end
  end
end
