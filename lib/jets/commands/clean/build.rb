require 'fileutils'

class Jets::Commands::Clean
  class Build < Base
    def clean
      are_you_sure?("delete /tmp/jets")

      say "Removing /tmp/jets..."
      FileUtils.rm_rf("/tmp/jets") unless @options[:noop]
      say "Removed /tmp/jets"
    end
  end
end
