require 'logger'
require 'active_support/dependencies'

module Jets::Util
  # Ensures trailing slash
  # Useful for appending a './' in front of a path or leaving it alone.
  # Returns: '/path/with/trailing/slash/' or './'
  @@root = nil
  def root
    return @@root if @@root
    @@root = ENV['PROJECT_ROOT'].to_s
    @@root = '.' if @@root == ''
    @@root = "#{@@root}/" unless @@root.ends_with?('/')
    @@root
  end

  @@logger = nil
  def logger
    return @@logger if @@logger
    @@logger = Logger.new($stderr)
  end

  # Load all application base classes and project classes
  def boot
    # puts "Jets.boot called".colorize(:red)
    autoload_paths = %w[
      app/controllers
      app/models
      app/jobs
    ].map { |p| "#{Jets.root}/#{p}" }
    ActiveSupport::Dependencies.autoload_paths += autoload_paths
  end

  def env
    Jets.config.env
  end

  def config
    Jets::Config.new.settings
  end

  @@build_root = nil
  def build_root
    @@build_root ||= "/tmp/jets/#{config.project_name}".freeze
  end
end
