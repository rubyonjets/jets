class Jets::Builders
  module Util
    def sh(command)
      puts "=> #{command}".colorize(:green)
      success = system(command)
      abort("#{command} failed to run") unless success
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

    def poly_only?
      Jets.poly_only?
    end
  end
end