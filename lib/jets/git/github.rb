module Jets::Git
  class Github < Base
    def info
      info = {
        git_system: "github",
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
      if build_type == "pull_request"
        pr.dig("pull_request", "head", "ref")
      else # push
        ENV["GITHUB_REF_NAME"]
      end
    end

    def git_sha
      if build_type == "pull_request"
        pr.dig("pull_request", "head", "sha")
      else # push
        ENV["GITHUB_SHA"]
      end
    end

    def git_url
      host = ENV["GITHUB_SERVER_URL"] || "https://github.com"
      full_repo = ENV["GITHUB_REPOSITORY"]
      "#{host}/#{full_repo}"
    end

    # GitHub webhook JSON payload in file and path is set in GITHUB_EVENT_PATH
    def pr
      return {} unless ENV["GITHUB_EVENT_PATH"]
      JSON.load(IO.read(ENV["GITHUB_EVENT_PATH"]))
    end

    def build_type
      ENV["GITHUB_EVENT_NAME"]
    end
  end
end
