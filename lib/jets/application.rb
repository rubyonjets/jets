require "singleton"
require "rack"

class Jets::Application
  include Singleton
  extend Memoist
  autoload :Middleware, "jets/middleware"
  include Jets::Middleware

  def configure(&block)
    instance_eval(&block) if block
  end

  def setup!
    load_configs
  end

  def finish!
    load_inflections
    setup_auto_load_paths
    load_routes
  end

  def load_inflections
    Jets::Inflections.load!
  end

  def config
    @config ||= ActiveSupport::OrderedOptions.new # dont use memoize since we reset @config later
  end

  def default_config
    config = ActiveSupport::OrderedOptions.new
    config.project_name = parse_project_name # must set early because other configs requires this
    config.cors = true
    config.autoload_paths = default_autoload_paths
    config.extra_autoload_paths = []

    # function properties defaults
    config.function = ActiveSupport::OrderedOptions.new
    config.function.timeout = 30
    # default memory setting based on:
    # https://medium.com/epsagon/how-to-make-lambda-faster-memory-performance-benchmark-be6ebc41f0fc
    config.function.memory_size = 1536

    config.prewarm = ActiveSupport::OrderedOptions.new
    config.prewarm.enable = true
    config.prewarm.rate = '30 minutes'
    config.prewarm.concurrency = 2
    config.prewarm.public_ratio = 3
    config.prewarm.rack_ratio = 5

    config.gems = ActiveSupport::OrderedOptions.new
    config.gems.sources = [
      Jets.default_gems_source
    ]

    config.inflections = ActiveSupport::OrderedOptions.new
    config.inflections.irregular = {}

    config.assets = ActiveSupport::OrderedOptions.new
    config.assets.folders = %w[assets images packs]
    config.assets.base_url = nil # IE: https://cloudfront.com/my/base/path
    config.assets.max_age = 3600
    config.assets.cache_control = nil # IE: public, max-age=3600 , max_age is a shorter way to set cache_control.

    config.ruby = ActiveSupport::OrderedOptions.new

    config.middleware = Jets::Middleware::Configurator.new

    config.session = ActiveSupport::OrderedOptions.new
    config.session.store = Rack::Session::Cookie # note when accessing it use session[:store] since .store is an OrderedOptions method
    config.session.options = {}

    config.api = ActiveSupport::OrderedOptions.new
    config.api.authorization_type = "NONE"
    config.api.binary_media_types = ['multipart/form-data']
    config.api.endpoint_type = 'EDGE' # PRIVATE, EDGE, REGIONAL

    config.domain = ActiveSupport::OrderedOptions.new
    # config.domain.name = "#{Jets.project_namespace}.coolapp.com" # Default is nil
    # config.domain.cert_arn = "..."
    config.domain.endpoint_type = "REGIONAL" # EDGE or REGIONAL. Default to EDGE because CloudFormation update is faster

    config
  end

  # Double evaling config/application.rb causes subtle issues:
  #   * double loading of shared resources: Jets::Stack.subclasses will have the same
  #   class twice when config is called when declaring a function
  #   * forces us to rescue all exceptions, which is a big hammer
  #
  # Lets parse for the project name instead for now.
  #
  def parse_project_name
    return ENV['JETS_PROJECT_NAME'] if ENV['JETS_PROJECT_NAME'] # override

    lines = IO.readlines("#{Jets.root}config/application.rb")
    project_name_line = lines.find { |l| l =~ /project_name/ }
    project_name_line.gsub(/.*=/,'').strip.gsub(/["']/,'') # project_name
  end

  def load_app_config
    @config = default_config
    set_dependent_configs! # things like project_namespace that need project_name
    eval_app_config # this overwrites Jets.config.project_name
    Jets.config.project_name = parse_project_name # Must set again because JETS_PROJECT_NAME is possible

    set_iam_policy # relies on dependent values, must be called afterwards
    normalize_env_vars!
  end

  def eval_app_config
    app_config = "#{Jets.root}config/application.rb"
    load app_config # use load instead of require so reload_configs! works
  end

  # After the mimimal template gets build, we need to reload it for the full stack
  # creation. This allows us to reference IAM policies configs that depend on the
  # creation of the s3 bucket.
  def reload_configs!
    load_configs
  end

  def load_environments_config
    env_file = "#{Jets.root}config/environments/#{Jets.env}.rb"
    if File.exist?(env_file)
      code = IO.read(env_file)
      instance_eval(code)
    end
  end

  def load_configs
    load_app_config
    load_db_config
    load_environments_config
    deprecated_configs_message
  end

  def deprecated_configs_message
    unless config.ruby.lazy_load.nil?
      puts "Detected config.ruby.lazy_load = #{config.ruby.lazy_load.inspect}".colorize(:yellow)
      puts "Deprecated: config.ruby.lazy_load".colorize(:yellow)
      puts "Gems are now bundled with with Lambda Layer and there's no need to lazy load them."
      puts "Please remove the config in your config/application.rb or config/environments files."
      puts "You can have Jets automatically do this by running:"
      puts "  jets upgrade:v1"
    end
  end

  def setup_auto_load_paths
    autoload_paths = config.autoload_paths + config.extra_autoload_paths
    # internal_autoload_paths are last
    autoload_paths += internal_autoload_paths
    ActiveSupport::Dependencies.autoload_paths += autoload_paths
  end

  # Essentially folders under app folder will be the default_autoload_paths. Example:
  #   app/controllers
  #   app/helpers
  #   app/jobs
  #   app/models
  #   app/rules
  #   app/shared/resources
  def default_autoload_paths
    paths = []
    Dir.glob("#{Jets.root}app/*").each do |p|
      p.sub!('./','')
      paths << p unless exclude_autoload_path?(p)
    end
    paths
  end

  def exclude_autoload_path?(path)
    path =~ %r{app/javascript} || path =~ %r{app/views}
  end

  def internal_autoload_paths
    internal = File.expand_path("../internal", __FILE__)
    paths = %w[
      app/controllers
      app/models
      app/jobs
    ]
    paths.map { |path| "#{internal}/#{path}" }
  end

  # Use the shorter name in stack names, but use the full name when it
  # comes to checking for the env.
  #
  # Example:
  #
  #   Jets.env: 'development'
  #   Jets.config.project_namespace: 'demo-dev'
  ENV_MAP = {
    development: 'dev',
    production: 'prod',
    staging: 'stag',
  }
  def set_dependent_configs!
    # env_extra can be also be set with JETS_ENV_EXTRA.
    # JETS_ENV_EXTRA higher precedence than config.env_extra
    config.env_extra = ENV['JETS_ENV_EXTRA'] if ENV['JETS_ENV_EXTRA']
    # IE: With env_extra: project-dev-1
    #     Without env_extra: project-dev
    config.short_env = ENV_MAP[Jets.env.to_sym] || Jets.env
    # table_namespace does not have the env_extra, more common case desired.
    config.table_namespace = [config.project_name, config.short_env].compact.join('-')

    config.project_namespace = Jets.project_namespace
  end

  def set_iam_policy
    config.iam_policy ||= self.class.default_iam_policy
    config.managed_policy_definitions ||= [] # default empty
  end

  def self.default_iam_policy
    project_namespace = Jets.project_namespace
    logs = {
      action: ["logs:*"],
      effect: "Allow",
      resource: "arn:aws:logs:#{Jets.aws.region}:#{Jets.aws.account}:log-group:/aws/lambda/#{project_namespace}-*",
    }
    s3_bucket = Jets.aws.s3_bucket
    s3_readonly = {
      action: ["s3:Get*", "s3:List*"],
      effect: "Allow",
      resource: "arn:aws:s3:::#{s3_bucket}*",
    }
    s3_bucket = {
      action: ["s3:ListAllMyBuckets", "s3:HeadBucket"],
      effect: "Allow",
      resource: "arn:aws:s3:::*", # scoped to all buckets
    }
    policies = [logs, s3_readonly, s3_bucket]

    if Jets::Stack.has_resources?
      cloudformation = {
        action: ["cloudformation:DescribeStacks"],
        effect: "Allow",
        resource: "arn:aws:cloudformation:#{Jets.aws.region}:#{Jets.aws.account}:stack/#{project_namespace}*",
      }
      policies << cloudformation
    end
    policies
  end

  # It is pretty easy to attempt to set environment variables without
  # the correct AWS Environment.Variables path struture.
  # Auto-fix it for convenience.
  def normalize_env_vars!
    environment = config.function.environment
    if environment and !environment.to_h.key?(:variables)
      config.function.environment = {
        variables: environment.to_h
      }
    end
  end

  def load_db_config
    config.database = {}

    Jets::Dotenv.load!
    database_yml = "#{Jets.root}config/database.yml"
    if File.exist?(database_yml)
      text = Jets::Erb.result(database_yml)
      db_config = YAML.load(text)
      config.database = db_config
    end
  end

  # Naming it routes because config/routes.rb requires
  #
  #   Jets.application.routes.draw do
  #
  # for scaffolding to work.
  def routes
    @router ||= Jets::Router.new
  end

  def load_routes
    routes_file = "#{Jets.root}config/routes.rb"
    require routes_file if File.exist?(routes_file)
  end

  def aws
    Jets::AwsInfo.new
  end
  memoize :aws

end
