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
    setup_auto_load_paths
    load_routes
  end

  def config
    config = ActiveSupport::OrderedOptions.new

    config.prewarm = ActiveSupport::OrderedOptions.new
    config.prewarm.enable = true
    config.prewarm.rate = '30 minutes'
    config.prewarm.concurrency = 2
    config.prewarm.public_ratio = 10

    config.lambdagems = ActiveSupport::OrderedOptions.new
    config.lambdagems.sources = [
      'https://gems.lambdagems.com'
    ]

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

    project_namespace = [config.project_name, config.short_env, config.env_extra].compact.join('-')
    config.project_namespace = project_namespace

    # Must set default iam_policy here instead of `def config` because we need access to
    # the project_namespace and if we call it from `def config` we get an infinit loop
    config.iam_policy ||= [{
      sid: "Statement1",
      action: ["logs:*"],
      effect: "Allow",
      resource: "arn:aws:logs:#{Jets.aws.region}:#{Jets.aws.account}:log-group:/aws/lambda/#{project_namespace}-*",
    }]
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
