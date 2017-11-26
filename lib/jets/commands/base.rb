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
  end
end
