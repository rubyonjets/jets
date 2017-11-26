require "thor"

class Jets::Command
  class Base < Thor
    class << self
      # def command_help(shell, command_name)
      #   meth = normalize_command_name(command_name)
      #   command = all_commands[meth]

      #   pp command
      #   unless command.long_description
      #     command.long_description = markdown_long_desc(meth)
      #   end

      #   super
      # end

      # def long_desc(long_description=nil, options = {})
      #   if long_description
      #     super
      #   else
      #     @long_desc ||= Jets::Erb.result(long_desc_path) if long_desc_path
      #   end
      # end

      # def long_desc_path
      #   # Jets::Commands::Dynamodb
      #   # self.to_s.underscore
      #   # puts "markdown_path "
      #   # path = File.expand_path("../#{}")
      #   # puts "File.expand_path: "
      #   puts "self #{self.inspect}"
      #   nil
      # end

      # def markdown_long_desc(meth)
      #   puts "class #{self.class}"
      #   puts "meth #{meth}"
      #   nil
      # end
      # TODO: re-enable after figure out the namespace thor hacks
      # def dispatch(m, args, options, config)
      #   # Allow calling for help via:
      #   #   jets command help
      #   #   jets command -h
      #   #   jets command --help
      #   #   jets command -D
      #   #
      #   # as well thor's normal way:
      #   #
      #   #   jets help command
      #   # raise "hell"
      #   help_flags = Thor::HELP_MAPPINGS + ["help"]
      #   if args.length > 1 && !(args & help_flags).empty?
      #     puts "inserting help in front"
      #     args -= help_flags
      #     args = args.insert(-2, "help")
      #     puts "args #{args.inspect}"
      #     args
      #   end
      #   super
      # end
    end
  end
end
