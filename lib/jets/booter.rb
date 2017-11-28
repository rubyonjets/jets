# Global overrides for Lambda processing
$stdout.sync = true
$stderr.sync = true
$stdout = $stderr
# $stdout = $stderr might seem weird but we want puts to write to stderr which
# is set in the node shim to write to stderr.  This directs the output to
# Lambda logs.
# Printing to stdout managles up the payload returned from Lambda function.
# This is not desired when returning payload to API Gateway eventually.

class Jets::Booter
  def boot!
    confirm_jets_project!
    puts boot_message

    require "bundler/setup"
    Bundler.require(*bundler_groups)

    Jets::Dotenv.load!

    Jets.application.setup! # app configs: autoload_paths, routes, etc
    connect_to_db
  end

  # Only connects connect to database for ActiveRecord and when
  # config/database.yml exists.
  # DynamodbModel handles connecting to the clients lazily.
  def connect_to_db
    database_yml = "#{Jets.root}config/database.yml"
    return unless File.exist?(database_yml)

    text = Jets::Erb.result(database_yml)
    config = YAML.load(text)
    ActiveRecord::Base.establish_connection(config[Jets.env])
  end

  def bundler_groups
    [:default, Jets.env.to_sym]
  end

  # Cannot call this for the jets new
  def confirm_jets_project!
    unless File.exist?("#{Jets.root}config/application.rb")
      puts "It does not look like you are running this command within a jets project.  Please confirm that you are in a jets project and try again.".colorize(:red)
      exit
    end
  end

  def boot_message
    self.class.boot_message
  end

  def self.boot_message
    "Jets booting up in #{Jets.env.colorize(:green)} mode!"
  end

end
