class Jets::CLI
  class Exec < Base
    def run
      if @options[:command].empty?
        Repl.new(options).start
      else
        Command.new(options).run
      end
    rescue Jets::CLI::Call::Error => e
      puts "ERROR: #{e.message}".color(:red)
      abort "Unable to find the function.  Please check the function name and try again."
    end
  end
end
