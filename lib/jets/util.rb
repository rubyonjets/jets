require 'logger'
require 'active_support/dependencies'

module Jets::Util
  # Ensures trailing slash
  # Useful for appending a './' in front of a path or leaving it alone.
  # Returns: '/path/with/trailing/slash/' or './'
  @@root = nil
  def root
    return @@root if @@root
    @@root = ENV['APP_ROOT'].to_s
    @@root = '.' if @@root == ''
    @@root = "#{@@root}/" unless @@root.ends_with?('/')
    @@root = Pathname.new(@@root)
  end

  # Load all application base classes and project classes
  def boot
    require "bundler/setup"
    Bundler.require(*Jets.groups)
    Jets::Dotenv.load!
    ActiveSupport::Dependencies.autoload_paths += autoload_paths
    connect_to_db
  end

  def groups
    [:default, Jets.env.to_sym]
  end

  def autoload_paths
    autoload_paths = config.autoload_paths + config.extra_autoload_paths
    autoload_paths.uniq.map { |p| "#{Jets.root}#{p}" }
  end

  def config
    application.config
  end

  # Calling application triggers load of configs.
  # Jets' the default config/application.rb is loaded,
  # then the project's config/application.rb is loaded.
  @@application = nil
  def application
    return @@application if @@application
    @@application = Jets::Application.new
    @@application.load_configs
    @@application
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

  @@env = nil
  def env
    return @@env if @@env

    env = ENV['JETS_ENV'] || 'development'
    ENV['RAILS_ENV'] = ENV['RACK_ENV'] = env
    @@env = ActiveSupport::StringInquirer.new(env)
  end

  @@build_root = nil
  def build_root
    @@build_root ||= "/tmp/jets/#{config.project_name}".freeze
  end

  @@logger = nil
  def logger
    return @@logger if @@logger
    @@logger = Logger.new($stderr)
  end

  # Make sure that this command is ran within a jets project
  def confirm_jets_project!
    unless File.exist?("#{Jets.root}config/application.rb")
      puts "It does not look like you are running this command within a jets project.  Please confirm that you are in a jets project and try again.".colorize(:red)
      exit
    end
  end
end
