# Global overrides for Lambda processing
$stdout.sync = true
# This might seem weird but we want puts to write to stderr which is set in
# the node shim to write to stderr.  This directs the output to Lambda logs.
# Printing to stdout can managle up the payload returned from Lambda function.
# This is not desired if you want to return say a json payload to API Gateway
# eventually.
def puts(text)
  $stderr.puts(text)
end
def print(text)
  $stderr.print(text)
end

class Jets::Booter
  def boot!
    # confirm_jets_project!

    $stderr.puts "Jets booting up in #{Jets.env.colorize(:green)} mode!"
    require "bundler/setup"
    Bundler.require(*bundler_groups)

    Jets::Dotenv.load!

    ActiveSupport::Dependencies.autoload_paths += autoload_paths

    connect_to_db
  end

  # Only need to do this for ActiveRecord. DynamodbModel handles connecting
  # to the client already.
  # Only connects if config/database.yml exists.
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

  def autoload_paths
    autoload_paths = Jets.config.autoload_paths + Jets.config.extra_autoload_paths
    autoload_paths.uniq.map { |p| "#{Jets.root}#{p}" }
  end

  # Make sure that this command is ran within a jets project
  def confirm_jets_project!
    unless File.exist?("#{Jets.root}config/application.rb")
      puts "It does not look like you are running this command within a jets project.  Please confirm that you are in a jets project and try again.".colorize(:red)
      exit
    end
  end

end
