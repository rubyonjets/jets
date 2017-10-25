require "thor"
require "lam/cli/help"

module Lam

  class CLI < Command
    class_option :verbose, type: :boolean
    class_option :noop, type: :boolean

    desc "build", "Builds and prepares project for Lambda"
    long_desc Help.build
    option :force, type: :boolean, aliases: "-f", desc: "override existing starter files"
    option :quiet, type: :boolean, aliases: "-q", desc: "silence the output"
    option :format, type: :string, default: "yaml", desc: "starter project template format: json or yaml"
    def build
      Lam::Build.new(options).run
    end

    desc "process TYPE", "process subcommand tasks"
    long_desc Help.process
    subcommand "process", Lam::Process
  end
end
