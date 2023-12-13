module Jets::Git
  class Info
    extend Memoist
    # Not using options but trying to future proof initialize
    def initialize(options = {})
      @options = options
    end

    def user
      User.new
    end
    memoize :user

    # Best effort to get git info
    def params
      return {} if ENV["JETS_GIT_DISABLED"]
      strategy_class.new.params
    end

    def strategy_class
      return Saved if File.exist?(".jets/gitinfo.yml")

      env_map = {
        BITBUCKET_COMMIT: Bitbucket,
        CIRCLECI: Circleci,
        CODEBUILD_CI: Codebuild,
        GITHUB_ACTIONS: Github,
        GITLAB_CI: Gitlab,
        JETS_GIT_CUSTOM: Custom,
        SYSTEM_TEAMFOUNDATIONSERVERURI: Azure
      }
      found = env_map.find do |env_key, strategy_class|
        ENV[env_key.to_s]
      end
      found ? found[1] : Local
    end
    memoize :strategy_class
  end
end
