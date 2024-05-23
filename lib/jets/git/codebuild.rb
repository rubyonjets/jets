module Jets::Git
  class Codebuild < Base
    def info
      info = {
        git_system: "codebuild",
        git_branch: git_branch,
        git_sha: git_sha,
        git_dirty: false,
        git_url: git_url
        # git_message: nil,
        # git_version: nil,
      }
      info.delete_if { |k, v| v.nil? }
      info
    end

    def git_branch
      ENV["CODEBUILD_SOURCE_VERSION"]
    end

    def git_sha
      ENV["CODEBUILD_RESOLVED_SOURCE_VERSION"]
    end

    def git_url
      "#{host}/#{full_repo}" if host && full_repo
    end

    def host
      return unless ENV["CODEBUILD_SOURCE_REPO_URL"]
      uri = URI(ENV["CODEBUILD_SOURCE_REPO_URL"]) # https://github.com/ORG/REPO
      "#{uri.scheme}://#{uri.host}"
    end

    # ORG/REPO
    def full_repo
      return unless repo_url
      uri = URI(repo_url)
      uri.path.sub(/^\//, "")
    end

    # https://github.com/ORG/REPO
    def repo_url
      return unless ENV["CODEBUILD_SOURCE_REPO_URL"]
      # https://github.com/ORG/REPO.git
      ENV["CODEBUILD_SOURCE_REPO_URL"].sub(".git", "")
    end
  end
end
