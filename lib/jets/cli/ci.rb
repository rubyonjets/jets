class Jets::CLI
  class Ci < Jets::Thor::Base
    Init.cli_options.each { |args| option(*args) }
    register(Init, "init", "init", "CI init creates config/jets/ci.rb")

    desc "build", "CI build cfn template"
    def build
      Build.new(options).run
    end

    desc "deploy", "CI deploy cfn stack"
    yes_option
    def deploy
      Deploy.new(options).run
    end

    desc "delete", "CI delete cfn stack"
    yes_option
    def delete
      Delete.new(options).run
    end

    desc "info", "CI info"
    format_option(default: "info")
    def info
      Info.new(options).run
    end

    desc "start", "CI start build"
    yes_option
    option :buildspec_override, desc: "Path to buildspec override file"
    option :branch, aliases: "b", desc: "git branch" # Default is nil. Will use what's configured on AWS CodeBuild project settings.
    option :env_vars, aliases: "e", type: :array, desc: "env var overrides. IE: KEY1=VALUE1 KEY2=VALUE2"
    def start
      Start.new(options).run
    end

    desc "status", "CI status of build"
    def status
      Status.new(options).run
    end

    desc "stop", "CI stop build"
    yes_option
    def stop
      Stop.new(options).run
    end

    desc "logs", "CI logs"
    yes_option
    def logs
      Logs.new(options).run
    end
  end
end
