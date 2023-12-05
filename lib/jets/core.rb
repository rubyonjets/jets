module Jets::Core
  extend Memoist

  mattr_accessor :cache

  delegate :aws, :autoloaders, :config, to: :application

  @application = @app_class = nil

  attr_writer :application
  attr_accessor :app_class
  def application
    @application ||= (app_class.instance if app_class)
  end

  def backtrace_cleaner
    @backtrace_cleaner ||= Jets::BacktraceCleaner.new
  end

  # The Configuration instance used to configure the Rails environment
  def configuration
    application.config
  end

  def root
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

  @@extra_warning_shown = false
  def extra
    # Keep for backwards compatibility
    unless ENV['JETS_ENV_EXTRA'].blank?
      puts "DEPRECATION WARNING: JETS_ENV_EXTRA is deprecated. Use JETS_EXTRA instead.".color(:yellow) unless @@extra_warning_shown
      @@extra_warning_shown = true
      extra = ENV['JETS_ENV_EXTRA']
    end
    extra = ENV['JETS_EXTRA'] unless ENV['JETS_EXTRA'].blank?
    extra
  end

  def project_name
    path = "config/project_name"
    if ENV['JETS_PROJECT_NAME'] && !ENV['JETS_PROJECT_NAME'].blank?
      ENV['JETS_PROJECT_NAME']
    elsif File.exist?(path)
      IO.read(path).strip
    elsif parsed_project_name
      parsed_project_name
    else
      Dir.pwd.split("/").last # conventionally infer app name from current directory
    end
  end

  def project_namespace
    [project_name, short_env, extra].compact.join('-').gsub('_','-')
  end

  def table_namespace
    [project_name, short_env].compact.join('-')
  end

  ENV_MAP = {
    development: 'dev',
    production: 'prod',
    staging: 'stag',
  }
  def short_env
    ENV_MAP[Jets.env.to_sym] || Jets.env
  end

  # Double evaling config/application.rb causes subtle issues:
  #   * double loading of shared resources: Jets::Stack.subclasses will have the same
  #   class twice when config is called when declaring a function
  #   * forces us to rescue all exceptions, which is a big hammer
  #
  # Lets parse for the project name instead for now.
  #
  # Keep for backwards compatibility
  def parsed_project_name
    lines = IO.readlines("#{Jets.root}/config/application.rb")
    project_name_line = lines.find { |l| l =~ /config\.project_name.*=/ && l !~ /^\s+#/ }
    if project_name_line
      parsed = project_name_line.gsub(/.*=/,'').strip
      # The +? makes it non-greedy
      # See: https://ruby-doc.org/core-2.5.1/Regexp.html#class-Regexp-label-Repetition
      md = parsed.match(/['"](.+?)['"]/)
      md ? md[1] : raise("Unable to parse project name from config/application.rb: #{project_name_line}")
    end
  end
  memoize :parsed_project_name

  # Load all application base classes and project classes
  def boot
    Jets::Booter.boot!
  end

  def build_root
    "/tmp/jets/#{Jets.project_name}".freeze
  end
  memoize :build_root

  def logger
    @logger
  end

  def logger=(logger)
    @logger = logger
  end

  def deprecator # :nodoc:
    @deprecator ||= ActiveSupport::Deprecation.new
  end

  def webpacker?
    Gem.loaded_specs.keys.any?{|k| k.start_with?("webpacker")}
  end
  memoize :webpacker?

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

  def poly_only?
    return true if ENV['JETS_POLY_ONLY'] # bypass to allow rapid development of handlers
    Jets::Cfn::Builder.poly_only?
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
    # require "jets/overrides/puma" # leaving around as a comment in case needed in the future
    tmp_load!
  end

  def tmp_load!
    Jets::TmpLoader.load!
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

  def one_lambda_per_controller?
    Jets.config.cfn.build.controllers == "one_lambda_per_controller"
  end

  def one_lambda_for_all_controllers?
    Jets.config.cfn.build.controllers == "one_lambda_for_all_controllers"
  end

  # Do not memoize here. The JetsBucket.name does it's own special memoization.
  def s3_bucket
    Jets::Cfn::Resource::S3::JetsBucket.name
  end

  def report_exception(exception)
    # See Jets::ExceptionReporting decorate_exception_with_exception_reported!
    if exception.respond_to?(:with_exception_reported?) && exception.with_exception_reported?
      return
    end

    Jets.application.turbines.each do |turbine|
      turbine.on_exception_blocks.each do |block|
        block.call(exception)
      end
    end
  end

  # Returns the ActiveSupport::ErrorReporter of the current \Jets project,
  # otherwise it returns +nil+ if there is no project.
  #
  #   Jets.error.handle(IOError) do
  #     # ...
  #   end
  #   Jets.error.report(error)
  def error
    application && application.executor.error_reporter
    # ActiveSupport.error_reporter
  end

  # Returns a Pathname object of the public folder of the current
  # \Jets project, otherwise it returns +nil+ if there is no project:
  #
  #   Jets.public_path
  #     # => #<Pathname:/Users/someuser/some/path/project/public>
  def public_path
    application && Pathname.new(application.paths["public"].first)
  end

  def autoloaders
    application.autoloaders
  end

  # It's useful to eager load and find out any error within the jets code immediately.
  # Leaving in place because think the layer of protection is good.
  # Eager load outside of a jets project can error. IE: `jets -h`
  # Eager load inside a jets project is fine.
  def eager_load_gem?
    File.exist?("config/application.rb") || ENV['JETS_TEST'] || defined?(ENGINE_ROOT) # jets project
  end
end
