require "thor"
require "byebug"

module Jets
  class Command < Thor
    class << self
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
