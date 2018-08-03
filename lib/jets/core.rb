require 'logger'
require 'active_support/dependencies'
require 'memoist'

module Jets::Core
  extend Memoist

  # Calling application triggers load of configs.
  # Jets' the default config/application.rb is loaded,
  # then the project's config/application.rb is loaded.
  def application
    application = Jets::Application.new
    application.setup!
    application
  end
  memoize :application

  def config
    application.config
  end

  # Load all application base classes and project classes
  def boot
    Jets::Booter.boot!
  end

  # Ensures trailing slash
  # Useful for appending a './' in front of a path or leaving it alone.
  # Returns: '/path/with/trailing/slash/' or './'
  def root
    root = ENV['JETS_ROOT'].to_s
    root = '.' if root == ''
    root = "#{root}/" unless root.ends_with?('/')
    Pathname.new(root)
  end
  memoize :root

  def env
    env = ENV['JETS_ENV'] || 'development'
    ENV['RAILS_ENV'] = ENV['RACK_ENV'] = env
    ActiveSupport::StringInquirer.new(env)
  end
  memoize :env

  def build_root
    "/tmp/jets/#{config.project_name}".freeze
  end
  memoize :build_root

  def logger
    Logger.new($stderr)
  end
  memoize :logger

  def load_tasks
    Jets::Commands::RakeTasks.load!
  end

  def webpacker?
    Gem.loaded_specs.keys.include?("webpacker")
  end
  memoize :webpacker?

  def version
    Jets::VERSION
  end
end
