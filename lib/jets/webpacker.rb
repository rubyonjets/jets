class Jets::Webpacker
  autoload :MiddlewareSetup, "jets/webpacker/middleware_setup"

  def self.run_command(*args)
    command = "bundle exec rake webpacker:#{args.join(':')}"
    puts "=> #{command}".colorize(:green)
    system command
  end
end
