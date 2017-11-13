require "jets"
require "bundler"
require "rake"
require "byebug"


class Jets::Db
  autoload :Tasks, 'jets/db/tasks'

  def initialize(options)
    @options = options
  end

  def run_command(*args)
    command = "bundle exec rake db:#{args.join(':')}"
    puts "=> #{command}".colorize(:green)
    system command
  end
end
