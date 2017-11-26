require "thor"

class Jets::Commands::Base < Thor
  class << self
    # Track all command subclasses.
    def subclasses
      @subclasses ||= []
    end

    def inherited(base)
      super

      if base.name && base.name !~ /Base$/
        self.subclasses << base
      end
    end

    # useful for help menu
    def eager_load!
      path = File.expand_path("../../", __FILE__)
      Dir.glob("#{path}/commands/**/*.rb").each do |path|
        require path
      end
    end

    # TODO: re-enable after figure out the namespace thor hacks
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
      yes = args.length > 1 && !(args & help_flags).empty?

      puts "args #{args.inspect}"
      puts "help_flags #{help_flags.inspect}"
      puts "yes #{yes.inspect}"
      exit
      if yes
        puts "inserting help in front"
        # args -= help_flags
        # args = args.insert(-2, "help")
        puts "args #{args.inspect}"
        # args
      end

      super
    end
  end
end
