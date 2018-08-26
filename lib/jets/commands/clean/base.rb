class Jets::Commands::Clean
  class Base
    def initialize(options={})
      @options = options
    end

  private
    def say(message)
      prefix = 'NOOP ' if @options[:noop]
      puts "#{prefix}#{message}" unless @options[:mute]
    end
  end
end