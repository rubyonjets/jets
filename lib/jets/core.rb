require 'logger'
require 'active_support/dependencies'
require 'memoist'

module Jets::Core
  extend Memoist

  # Calling application triggers load of configs.
  # Jets' the default config/application.rb is loaded,
  # then the project's config/application.rb is loaded.
  @@application = nil
  def application
    return @@application if @@application

    @@application = Jets::Application.new
    @@application.setup!
    @@application
  end
  # For some reason memoize doesnt work with application, think there's
  # some circular dependency issue. Figure this out later.

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
  # @@root = nil
  # def root
  #   return @@root if @@root
  #   @@root = ENV['JETS_ROOT'].to_s
  #   @@root = '.' if @@root == ''
  #   @@root = "#{@@root}/" unless @@root.ends_with?('/')
  #   @@root = Pathname.new(@@root)
  # end

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

  def webpacker?
    Gem.loaded_specs.keys.include?("webpacker")
  end
  memoize :webpacker?

  def load_tasks
    Jets::Commands::RakeTasks.load!
  end

  def version
    Jets::VERSION
  end
  
  def eager_load!
    Dir.glob("#{Jets.root}app/**/*.rb").select do |path|
      next if !File.file?(path) or path =~ /javascript/ or path =~ %r{/views/}

      class_name = path
                    .sub(/\.rb$/,'') # remove .rb
                    .sub(/^\.\//,'') # remove ./
                    .sub(/app\/\w+\//,'') # remove app/controllers or app/jobs etc
                    .classify
      puts "eager_load! loading path: #{path} class_name: #{class_name}" if ENV['DEBUG']
      class_name.constantize # dont have to worry about order.
    end
  end

end
