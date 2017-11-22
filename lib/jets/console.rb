class Jets::Console
  def self.run
    # Thanks: https://mutelight.org/bin-console
    require "irb"
    require "irb/completion"

    Jets.boot

    ARGV.clear # https://stackoverflow.com/questions/33070092/irb-start-not-starting/33136762
    IRB.start
  end
end
