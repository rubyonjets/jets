class Jets::Console
  def self.run
    # Thanks: https://mutelight.org/bin-console
    require "irb"
    require "irb/completion"
    require "bundler/setup"
    Bundler.require(:default)

    Dir.glob("app/**/*").each do |path|
      next unless File.file?(path)
      require "#{Jets.root}#{path}"
    end

    ARGV.clear # https://stackoverflow.com/questions/33070092/irb-start-not-starting/33136762
    IRB.start
  end
end
