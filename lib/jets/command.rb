require "thor"

module Jets
  class Command < Thor
    class << self
      def dispatch(m, args, options, config)
        # Allow calling for help via:
        #   jets command help
        #   jets command -h
        #   jets command --help
        #   jets command -D
        #
        # as well thor's normal way:
        #
        #   jets help command
        help_flags = Thor::HELP_MAPPINGS + ["help"]
        if args.length > 1 && !(args & help_flags).empty?
          args -= help_flags
          args.insert(-2, "help")
        end
        super
      end
    end
  end
end
