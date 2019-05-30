module Jets::Builders
  module Util
  private
    def sh(command)
      puts "=> #{command}".color(:green)
      success = system(command)
      unless success
        puts "#{command} failed to run.".color(:red)
        puts caller[0]
        exit 1
      end
      success
    end

    def headline(message)
      puts "=> #{message}".color(:cyan)
    end

    def build_area
      Jets.build_root
    end

    def stage_area
      "#{build_area}/stage"
    end

    def cache_area
      "#{build_area}/cache" # cleaner to use full path for this setting
    end
  end
end