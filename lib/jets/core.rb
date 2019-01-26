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
  def boot(options={})
    Jets::Booter.boot!(options)
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

  def eager_load!
    eager_load_jets
    eager_load_app
  end

  # Eager load jet's lib and classes
  def eager_load_jets
    lib_jets = File.expand_path(".", File.dirname(__FILE__))
    Dir.glob("#{lib_jets}/**/*.rb").select do |path|
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
    path =~ %r{/cli} ||
    path =~ %r{/core_ext} ||
    path =~ %r{/default/application} ||
    path =~ %r{/functions} ||
    path =~ %r{/internal/app} ||
    path =~ %r{/jets/stack} ||
    path =~ %r{/overrides} ||
    path =~ %r{/rackup_wrappers} ||
    path =~ %r{/reconfigure_rails} ||
    path =~ %r{/templates/} ||
    path =~ %r{/turbo/project/} ||
    path =~ %r{/version} ||
    path =~ %r{/webpacker} ||
    path =~ %r{/jets/spec}
  end

  def class_mappings(class_name)
    map = {
      "Jets::Io" => "Jets::IO",
    }
    map[class_name] || class_name
  end

  # Eager load user's application
  def eager_load_app
    Dir.glob("#{Jets.root}/app/**/*.rb").select do |path|
      next if !File.file?(path) or path =~ %r{/javascript/} or path =~ %r{/views/}
      next if path.include?('app/functions') || path.include?('app/shared/functions') || path.include?('app/internal/functions')

      class_name = path
                    .sub(/\.rb$/,'') # remove .rb
                    .sub(%{^\./},'') # remove ./
                    .sub("#{Jets.root}/",'')
                    .sub(%r{app/shared/\w+/},'') # remove shared/resources or shared/extensions
                    .sub(%r{app/\w+/},'') # remove app/controllers or app/jobs etc
      class_name = class_name.classify
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

  def process(event, context, handler)
    if event['_prewarm']
      Jets.increase_prewarm_count
      Jets.logger.info("Prewarm request")
      {prewarmed_at: Time.now.to_s}
    else
      Jets::Processors::MainProcessor.new(event, context, handler).run
    end
  end

  # Example: Jets.handler(self, "handlers/controllers/posts_controller.index")
  def handler(lambda_context, handler)
    meth = handler.split('.').last
    lambda_context.send(:define_method, meth) do |event:, context:|
      Jets.process(event, context, handler)
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

  def default_gems_source
    "https://gems2.lambdagems.com"
  end

  def override_lambda_ruby_runtime
    require "jets/overrides/lambda"
  end
end
