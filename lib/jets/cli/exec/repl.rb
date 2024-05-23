require "fileutils"
require "open3"
require "readline"

class Jets::CLI::Exec
  class Repl
    extend Memoist
    include Jets::Util::Logging

    attr_reader :history
    def initialize(options = {})
      @options = options
      @history = History.new(@options) # load for history to work upon start
      trap_signals
    end

    def start
      welcome

      loop do
        input = Readline.readline("$ ", true)

        if input.nil? || input.downcase == "exit"
          puts "Exiting..."
          history.save
          break
        elsif input.strip.empty?
          next
        elsif input.strip.start_with? "history"
          num = input.split(" ")[1]
          history.display(num)
          next
        elsif input.strip.start_with? "!"
          execute_from_history(input)
          next
        elsif input.strip == "status"
          display_last_status
          next
        elsif %w[_ result].include?(input.strip)
          display_last_result
          next
        elsif %w[help ?].include?(input.strip)
          display_help
          next
        end

        if history.list.empty? || input != history.list.last
          history.add(input)
        end
        execute_command(input)
      end
    end

    private

    def welcome
      function_name = Command.new(@options).function_name
      puts <<~EOL
        Jets REPL (#{Jets::VERSION}). Commands will be executed on Lambda.
        Lambda function: #{function_name}
        Type 'help' for help, 'exit' to exit.
      EOL
    end

    def execute_command(input)
      result = Command.new(@options.merge(command: input)).run
      @last_status = result["errorMessage"] ? 1 : result["status"]
      @last_result = result
    end

    def execute_from_history(input)
      index = input[1..-1].to_i - 1
      if index >= 0 && index < history.list.length
        input = history.list[index]
        puts "> #{input}"
        execute_command(input)
      else
        puts "Invalid history number"
      end
    end

    def display_last_status
      case @last_status
      when nil
        puts "No command has been executed on Lambda yet."
      when 0
        puts "Last command had a status of success (0)."
      else
        puts "Last command had a status other than success (#{@last_status})."
      end
    end

    def display_last_result
      if @last_result
        puts "Last result:"
        puts JSON.pretty_generate(@last_result)
      else
        puts "No command has been executed on Lambda yet."
      end
    end

    def display_help
      puts <<~HELP
        Available commands:
          - history [n or 'all']: Display the last n commands or the all command history. (Default: 20)
          - status: Display the status of the last command executed on Lambda.
          - result or _: Show previous command result.
          - help: Display this help message.
          - !<number>: Execute the command from the history by number.
          - exit: Exit the REPL. You can also use Control-D.
      HELP
    end

    def trap_signals
      Signal.trap("INT") do
        puts "\nExiting..."
        history.save
        exit
      end
    end
  end
end
