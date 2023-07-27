class Jets::Commands::Console
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
