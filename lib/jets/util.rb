require 'logger'
require 'active_support/dependencies'

module Jets::Util
  # Ensures trailing slash
  # Useful for appending a './' in front of a path or leaving it alone.
  # Returns: '/path/with/trailing/slash/' or './'
  @@root = nil
  def root
    return @@root if @@root
    @@root = ENV['JETS_ROOT'].to_s
    @@root = '.' if @@root == ''
    @@root = "#{@@root}/" unless @@root.ends_with?('/')
    @@root = Pathname.new(@@root)
  end

  # Load all application base classes and project classes
  def boot
    Jets::Booter.new.boot!
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
end
