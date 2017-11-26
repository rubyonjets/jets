require "thor"

class Jets::Commands::Base < Thor
  class << self
    # Track all command subclasses.
    def subclasses
      @subclasses ||= []
    end

    def inherited(base)
      super

      self.subclasses << base if base.name
    end

    # useful for help menu
    def eager_load!
      path = File.expand_path("../../", __FILE__)
      Dir.glob("#{path}/commands/**/*.rb").each do |path|
        require path
      end
    end

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
