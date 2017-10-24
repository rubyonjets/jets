require "thor"
require "lam/cli/help"

module Lam

  class CLI < Command
    class_option :verbose, type: :boolean
    class_option :noop, type: :boolean

    desc "process TYPE", "process subcommand tasks"
    long_desc Help.process
    subcommand "process", Lam::Process
  end
end
