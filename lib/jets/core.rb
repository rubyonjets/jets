module Jets::Core
  extend Memoist

  def application
    Jets::Application.instance
  end

  def config
    application.config
  end

  def aws
    application.aws
  end

  # Load all application base classes and project classes
  def boot
    Jets::Booter.boot!
  end

  def root
    # Do not memoize this method. Turbo mode can change it
    root = ENV['JETS_ROOT'].to_s
    root = Dir.pwd if root == ''
    Pathname.new(root)
  end

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
    Jets.application.config.logger
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

  def project_namespace
    [config.project_name, config.short_env, config.env_extra].compact.join('-').gsub('_','-')
  end

  def rack?
    path = "#{Jets.root}/rack"
    File.exist?(path) || File.symlink?(path)
  end

  def poly_only?
    return true if ENV['JETS_POLY_ONLY'] # bypass to allow rapid development of handlers
    Jets::Commands::Build.poly_only?
  end

  def report_exception(exception)
    puts "DEPRECATED: report_exception. Use on_exception instead.".color(:yellow)
    on_exception(exception)
  end

  def on_exception(exception)
    Jets::Turbine.subclasses.each do |subclass|
      reporters = subclass.on_exceptions || []
      reporters.each do |label, block|
        block.call(exception)
      end
    end
  end

  def custom_domain?
    Jets.config.domain.hosted_zone_name
  end

  def s3_event?
    !Jets::Job::Base.s3_events.empty?
  end

  def process(event, context, handler)
    if event['_prewarm']
      Jets.increase_prewarm_count
      Jets.logger.info("Prewarm request")
      {prewarmed_at: Time.now.to_s}
    else
      Jets::Processors::MainProcessor.new(event, context, handler).run
    end
  end

  def once
    boot
    override_lambda_ruby_runtime
    tmp_load!
    start_rack_server
  end

  def tmp_load!
    Jets::TmpLoader.load!
  end

  # Megamode support
  def start_rack_server(options={})
    rack = Jets::RackServer.new(options)
    rack.start
    rack.wait_for_socket
  end

  def override_lambda_ruby_runtime
    require "jets/overrides/lambda"
  end

  def ruby_folder
    RUBY_VERSION.split('.')[0..1].join('.') + '.0'
  end

  # used to configure internal lambda functions
  # current ruby runtime that user is running
  # IE: ruby2.5 ruby2.7
  def ruby_runtime
    version = RUBY_VERSION.split('.')[0..1].join('.')
    "ruby#{version}"
  end
end
