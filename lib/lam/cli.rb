require "thor"
require "lam/cli/help"

module Lam

  class CLI < Command
    class_option :verbose, type: :boolean
    class_option :noop, type: :boolean

    desc "hello NAME", "say hello to NAME"
    long_desc Help.hello
    option :from, desc: "from person"
    def hello(name)
      puts "from: #{options[:from]}" if options[:from]
      puts "Hello #{name}"
    end

    desc "process TYPE", "process subcommand tasks"
    long_desc Help.process
    subcommand "process", Lam::Process
  end
end
