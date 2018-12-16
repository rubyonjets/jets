class Jets::Commands::Import
  class Rack < Base
    def install
      bundle_install
    end

    def finish_message
      puts <<~EOL
        #{"="*30}
        Congrats! The Rack project from #{@source} has been imported to the rack folder.

        Note, generic rack projects will likely need some adjustments to take into account API Gateway stages and logging. For more info refer to [Mega Mode Considerations](http://rubyonjets.com//megamode-details/).
      EOL
    end
  end
end
