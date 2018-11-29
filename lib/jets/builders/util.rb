class Jets::Builders
  module Util
    def sh(command)
      puts "=> #{command}".colorize(:green)
      success = system(command)
      unless success
        puts "#{command} failed to run.".colorize(:red)
        puts caller[0]
        exit 1
      end
      success
    end

    def headline(message)
      puts "=> #{message}".colorize(:cyan)
    end

    # Provide pretty clear way to desinate full path.
    # full("bundled") => /tmp/jets/demo/bundled
    def full(relative_path)
      "#{Jets.build_root}/#{relative_path}"
    end

    def stage_area
      "#{Jets.build_root}/stage"
    end

    def code_area
      "#{stage_area}/code"
    end
  end
end