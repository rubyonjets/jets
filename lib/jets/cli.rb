require "thor"
require "jets/cli/help"

module Jets

  class CLI < Command
    class_option :verbose, type: :boolean
    class_option :noop, type: :boolean

    desc "build", "Builds and prepares project for Lambda"
    long_desc Help.build
    def build
      Jets::Build.new(options).run
    end

    desc "deploy", "Deploys project to Lambda"
    long_desc Help.deploy
    def deploy
      Jets::Deploy.new(options).run
    end

    desc "process TYPE", "process subcommand tasks"
    subcommand "process", Jets::Process
  end
end
