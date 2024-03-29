# frozen_string_literal: true

require "irb"
require "irb/completion"

module Jets::Command
  class ConsoleCommand < Base # :nodoc:
    include EnvironmentArgument

    desc "console", "REPL console with Jets environment loaded"
    long_desc Help.text(:console)
    def perform
      extract_environment_option_from_argument
      require_application_and_environment!
      Console.new(options).run
    end
  end

  class Console
    attr_reader :environment

    def initialize(environment)
      @environment = environment
    end

    def run
      puts Jets::Booter.message

      # Thanks: https://mutelight.org/bin-console
      require "irb"
      require "irb/completion"

      ARGV.clear # https://stackoverflow.com/questions/33070092/irb-start-not-starting/33136762
      IRB.start
    end
  end

end
