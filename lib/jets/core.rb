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

  def aws
    application.aws
  end

  # Load all application base classes and project classes
  def boot(options={})
    Jets::Booter.boot!(options)
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
    Jets::Logger.new($stderr)
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
    eager_load_jets
    eager_load_app
  end

  # Eager load jet's lib and classes
  def eager_load_jets
    lib_jets = File.expand_path(".", File.dirname(__FILE__))
    Dir.glob("#{lib_jets}/**/*.rb").select do |path|
      # puts "path #{path}"
      next if !File.file?(path)
      next if skip_eager_load_paths?(path)

      path = path.sub("#{lib_jets}/","jets/")
      class_name = path
                    .sub(/\.rb$/,'') # remove .rb
                    .sub(/^\.\//,'') # remove ./
                    .sub(/app\/\w+\//,'') # remove app/controllers or app/jobs etc
                    .camelize
      # special class mappings
      class_name = class_mappings(class_name)
      class_name.constantize # use constantize instead of require so dont have to worry about order.
    end
  end

  # Skip these paths because eager loading doesnt work for them.
  def skip_eager_load_paths?(path)
    path =~ %r{/templates/} ||
    path =~ %r{/version} ||
    path =~ %r{/rails_overrides} ||
    path =~ %r{/default/application} ||
    path =~ %r{/internal/app} ||
    path =~ %r{/webpacker} ||
    path =~ %r{/cli} ||
    path =~ %r{/core_ext}
  end

  def class_mappings(class_name)
    map = {
      "Jets::Io" => "Jets::IO",
    }
    map[class_name] || class_name
  end

  # Eager load user's application
  def eager_load_app
    Dir.glob("#{Jets.root}app/**/*.rb").select do |path|
      next if !File.file?(path) or path =~ %r{/javascript/} or path =~ %r{/views/}

      class_name = path
                    .sub(/\.rb$/,'') # remove .rb
                    .sub(/^\.\//,'') # remove ./
                    .sub(/app\/\w+\//,'') # remove app/controllers or app/jobs etc
                    .classify
      # puts "eager_load! loading path: #{path} class_name: #{class_name}" if ENV['JETS_DEBUG']
      class_name.constantize # use constantize instead of require so dont have to worry about order.
    end
  end

  # NOTE: In development this will always be 1 because the app gets reloaded.
  # On AWS Lambda, this will be ever increasing until the container gets replaced.
  @@call_count = 0
  def increase_call_count
    @@call_count += 1
  end

  def call_count
    @@call_count
  end

  @@prewarm_count = 0
  def increase_prewarm_count
    @@prewarm_count += 1
  end

  def prewarm_count
    @@prewarm_count
  end

end
