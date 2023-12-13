module Jets::Git
  class Azure < Base
    def info
      info = {
        git_system: "azure",
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
      if pr_number
        message = ENV["BUILD_SOURCEVERSIONMESSAGE"]
        md = message.match(/Merge pull request \d+ from (.*) into (.*)/)
        if md
          # IE: BUILD_SOURCEVERSIONMESSAGE=Merge pull request 2 from feature into main
          # Its a bit weird but with azure repos with check policy trigger
          md[1]
        else # GitHub and Bitbucket PR has actual branch though
          # IE: SYSTEM_PULLREQUEST_SOURCEBRANCH=feature
          message
        end
      else # push
        ENV["BUILD_SOURCEBRANCHNAME"]
      end
    end

    def git_sha
      ENV["BUILD_SOURCEVERSION"]
    end

    def git_url
      "#{host}/#{full_repo}"
    end

    # IE: BUILD_REPOSITORY_URI=https://tongueroo@dev.azure.com/tongueroo/infra-project/_git/infra-ci
    def host
      uri = URI(ENV["BUILD_REPOSITORY_URI"])
      "#{uri.scheme}://#{uri.host}"
    end

    # IE: BUILD_REPOSITORY_URI=https://tongueroo@dev.azure.com/tongueroo/infra-project/_git/infra-ci
    def full_repo
      uri = URI(ENV["BUILD_REPOSITORY_URI"])
      org = uri.path.split("/")[1] # since there's a leading /
      repo = ENV["BUILD_REPOSITORY_NAME"] # tongueroo
      "#{org}/#{repo}"
    end

    # IE: SYSTEM_PULLREQUEST_PULLREQUESTID=2
    def pr_number
      ENV["SYSTEM_PULLREQUEST_PULLREQUESTID"]
    end

    def build_type
      ENV["SYSTEM_PULLREQUEST_PULLREQUESTID"] ? "pull_request" : "push"
    end
  end
end
