require "singleton"
require "rack"

class Jets::Application
  include Singleton
  extend Memoist
  include Jets::Middleware
  include Defaults

  def configure(&block)
    instance_eval(&block) if block
  end

  def setup!
    load_default_config
    setup_autoload_paths
    setup_ignore_paths
    main_loader_setup
  end

  def configs!
    load_environments_config
    load_db_config
    set_iam_policy # relies on dependent values, must be called afterwards
    set_time_zone
    normalize_env_vars!
  end

  # After the mimimal template gets build, we need to reload it for the full stack
  # creation. This allows us to reference IAM policies configs that depend on the
  # creation of the s3 bucket.
  def reload_configs!
    # Tricky: reset only the things that depends on the minimal stack
    @config.iam_policy = nil
    configs!
  end

  def finish!
    deprecated_configs_message
    load_inflections
    load_routes

    Jets::Controller::Rendering::RackRenderer.setup! # Sets up ActionView etc
    # Load libraries at the end to trigger onload so we can defined options in any order.
    # Only action_mailer library have been used properly this way so far.
    require 'action_mailer'
  end

  def load_inflections
    Jets::Inflections.load!
  end

  def config
    @config ||= ActiveSupport::OrderedOptions.new # dont use memoize since we reset @config later
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

    lines = IO.readlines("#{Jets.root}/config/application.rb")
    project_name_line = lines.find { |l| l =~ /config\.project_name.*=/ && l !~ /^\s+#/ }
    project_name_line.gsub(/.*=/,'').strip.gsub(/["']/,'') # project_name
  end

  def load_default_config
    @config = default_config # sets Jets.config.project_name by calling parse_project_name
    set_computed_configs! # things like project_namespace that need project_name
    Jets::Dotenv.load! # needs Jets.config.project_name when using ssm in dotenv files
    Jets.config.project_name = parse_project_name # Must set again because JETS_PROJECT_NAME is possible
    load_config_application # this overwrites Jets.config.project_name
  end

  def load_config_application
    app_config = "#{Jets.root}/config/application.rb"
    load app_config # use load instead of require so reload_configs! works
  end

  def load_environments_config
    env_file = "#{Jets.root}/config/environments/#{Jets.env}.rb"
    if File.exist?(env_file)
      code = IO.read(env_file)
      instance_eval(code, env_file)
    end
  end

  def deprecated_configs_message
    unless config.ruby.lazy_load.nil?
      puts "Detected config.ruby.lazy_load = #{config.ruby.lazy_load.inspect}".color(:yellow)
      puts "Deprecated: config.ruby.lazy_load".color(:yellow)
      puts "Gems are now bundled with with Lambda Layer and there's no need to lazy load them."
      puts "Please remove the config in your config/application.rb or config/environments files."
      puts "You can have Jets automatically do this by running:"
      puts "  jets upgrade"
    end
  end

  def main_loader
    Jets::Autoloaders.main
  end

  def setup_autoload_paths
    autoload_paths = default_autoload_paths + config.autoload_paths
    autoload_paths.each do |path|
      next unless File.exist?(path)
      main_loader.push_dir(path)
    end
  end

  # Allow use to add config.ignore_paths just in case there's some case Jets hasn't considered
  def setup_ignore_paths
    ignore_paths = default_ignore_paths + config.ignore_paths
    ignore_paths.each do |path|
      main_loader.ignore("#{Jets.root}/#{path}")
    end
  end

  def main_loader_setup
    main_loader.enable_reloading if Jets.env.development?
    main_loader.setup # only respected on the first call
  end

  def each_app_autoload_path(expression)
    Dir.glob(expression).each do |p|
      p.sub!('./','')
      yield(p) unless exclude_autoload_path?(p)
    end
  end

  def exclude_autoload_path?(path)
    path =~ %r{app/javascript} ||
    path =~ %r{app/views} ||
    path =~ %r{/functions} # app and shared
  end

  def internal_autoload_paths
    internal = File.expand_path("../internal", __FILE__)
    paths = %w[
      app/controllers
      app/helpers
      app/jobs
      app/models
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
  def set_computed_configs!
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
    config.iam_policy ||= []
    config.default_iam_policy ||= self.class.default_iam_policy
    config.iam_policy = config.default_iam_policy | config.iam_policy
    config.managed_policy_definitions ||= [] # default empty
  end

  def set_time_zone
    Time.zone_default = Time.find_zone!(config.time_zone)
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

  def load_db_config(database_yml="#{Jets.root}/config/database.yml")
    config.database = {}

    Jets::Dotenv.load!
    if File.exist?(database_yml)
      require "active_record/database_configurations" # lazy require
      text = Jets::Erb.result(database_yml)
      db_configs = YAML.load(text)
      configurations = ActiveRecord::DatabaseConfigurations.new(db_configs)
      config.database = configurations
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

  def load_routes(refresh: false)
    @router = nil if refresh # clear_routes

    routes_file = "#{Jets.root}/config/routes.rb"
    return unless File.exist?(routes_file)
    if refresh
      load routes_file # always evaluate
    else
      require routes_file # evaluate once
    end
  end

  def aws
    Jets::AwsInfo.new
  end
  memoize :aws

end
