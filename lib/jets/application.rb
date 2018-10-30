require "active_support/ordered_options"

class Jets::Application
  extend Memoist
  # Middleware used for development only
  autoload :Middleware, "jets/application/middleware"
  include Middleware

  def configure(&block)
    instance_eval(&block) if block
  end

  def setup!
    load_configs # load config object so following methods can use it
    load_inflections
    setup_auto_load_paths
    load_routes
  end

  def load_inflections
    Jets::Inflections.load!
  end

  # Default config
  def config
    config = ActiveSupport::OrderedOptions.new

    config.prewarm = ActiveSupport::OrderedOptions.new
    config.prewarm.enable = true
    config.prewarm.rate = '30 minutes'
    config.prewarm.concurrency = 2
    config.prewarm.public_ratio = 3

    config.lambdagems = ActiveSupport::OrderedOptions.new
    config.lambdagems.sources = [
      'https://gems.lambdagems.com'
    ]

    config.inflections = ActiveSupport::OrderedOptions.new
    config.inflections.irregular = {}

    config.assets = ActiveSupport::OrderedOptions.new
    config.assets.folders = %w[public]
    config.assets.base_url = nil # IE: https://cloudfront.com/my/base/path
    config.assets.max_age = 3600
    config.assets.cache_control = nil # IE: public, max-age=3600 , max_age is a shorter way to set cache_control.

    config.ruby = ActiveSupport::OrderedOptions.new
    config.ruby.lazy_load = true # also set in config/environments files

    config
  end
  memoize :config

  def setup_auto_load_paths
    autoload_paths = config.autoload_paths + config.extra_autoload_paths
    autoload_paths = autoload_paths.uniq.map { |p| "#{Jets.root}#{p}" }
    # internal_autoload_paths are last
    autoload_paths += internal_autoload_paths
    ActiveSupport::Dependencies.autoload_paths += autoload_paths
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

  def load_configs
    # The Jets default/application.rb is loaded.
    require File.expand_path("../default/application.rb", __FILE__)
    # Then project config/application.rb is loaded.
    app_config = "#{Jets.root}config/application.rb"
    require app_config if File.exist?(app_config)
    # Normalize config and setup some shortcuts
    set_aliases!
    normalize_env_vars!
    load_db_config
    load_environments_config
  end

  def load_environments_config
    env_file = "#{Jets.root}config/environments/#{Jets.env}.rb"
    if File.exist?(env_file)
      code = IO.read(env_file)
      instance_eval(code)
    end
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
  def set_aliases!
    # env_extra can be also be set with JETS_ENV_EXTRA.
    # JETS_ENV_EXTRA higher precedence than config.env_extra
    config.env_extra = ENV['JETS_ENV_EXTRA'] if ENV['JETS_ENV_EXTRA']
    # IE: With env_extra: project-dev-1
    #     Without env_extra: project-dev
    config.short_env = ENV_MAP[Jets.env.to_sym] || Jets.env
    # table_namespace does not have the env_extra, more common case desired.
    config.table_namespace = [config.project_name, config.short_env].compact.join('-')

    config.project_namespace = Jets.project_namespace

    # Must set default iam_policy here instead of `def config` because we  project_namespace
    # must have been set and if we call it from `def config` we get an infinite loop
    set_iam_policy
  end

  def set_iam_policy
    config.iam_policy ||= self.class.default_iam_policy
    config.managed_policy_definitions ||= [] # default empty
  end

  # After the mimimal template gets build, we need to reload it for the full stack
  # creation. This is confusing to follow. Think we need to clean up the Jets.application
  # singleton and make it more explicit?
  def reload_iam_policy!
    config.iam_policy = nil
    config.managed_policy_definitions = nil
    set_iam_policy
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
