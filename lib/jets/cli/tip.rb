class Jets::CLI
  class Tip
    class << self
      def show(name, options = {})
        new(name).show(options)
      end
    end

    delegate :config, to: "Jets.project"

    def initialize(name)
      @name = name
    end

    def show(options = {})
      return if already_configured?
      return unless enabled?
      puts send(@name)
      puts disable_howto unless options[:disable_howto] == false
    end

    def already_configured?
      if @name == :faster_deploy
        config = Jets.bootstrap.config
        config.codebuild.project.env.vars.key?(:DOCKER_HOST) ||
          config.codebuild.fleet.enable ||
          config.codebuild.fleet_override
      else
        false
      end
    end

    def faster_deploy
      <<~EOL
        Tip: You can speed the deploy with one of these options:

        * Docker Remote Host: https://docs.rubyonjets.com/docs/remote/codebuild/docker/
        * CodeBuild Fleet: https://docs.rubyonjets.com/docs/remote/codebuild/fleet/

        Enabling of those options will also remove this message.
      EOL
    end

    def concurrency_change
      <<~EOL

        Note: CLI changes to concurrency are outside of deployment
      EOL
    end

    def env_change
      <<~EOL

        Note: CLI changes to env vars are outside of deployment
        See: https://docs.rubyonjets.com/env/cli/
      EOL
    end

    def ssm_change
      <<~EOL
        After deleting a parameter, wait for at least 30 seconds
        to create a parameter with the same name
      EOL
    end

    def disable_howto
      <<~EOL
        To disable this tip:

        * set config.tips.#{@name} = false in config/jets/project.rb
        * See: https://docs.rubyonjets.com/docs/more/cli-tips/
      EOL
    end

    def remote_run
      <<~EOL
        Ctrl-C will stop showing logs. Jets will continue to run remotely.
        If you want to stop the remote process, use: jets stop
      EOL
    end

    def enabled?
      config.tips.enable && config.tips[@name]
    end
  end
end
