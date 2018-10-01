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

    # Finds out of the app has polymorphic functions only and zero ruby functions.
    # In this case, we can skip a lot of the ruby related building and speed up the
    # deploy process.
    def poly_only?
      return true if ENV['POLY_ONLY'] # bypass to allow rapid development of handlers
      Jets::Commands::Build.poly_only?
    end
  end
end