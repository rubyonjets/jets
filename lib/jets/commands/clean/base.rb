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

    def are_you_sure?(message)
      return true if @options[:yes]

      puts "Are you sure that you want to #{message}? (y/N)"
      yes = $stdin.gets.strip
      unless yes =~ /^y/
        puts "Phew that was close!"
        exit 0
      end
    end
  end
end