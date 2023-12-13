require "fileutils"

class Jets::CLI
  class Clean < Base
    def run
      FileUtils.rm_rf(Jets.build_root)
      puts "Removed #{Jets.build_root}"
    end
  end
end
