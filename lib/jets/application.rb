require "recursive-open-struct"

class Jets::Application
  # Middleware used for development only
  autoload :Middleware, "jets/application/middleware"
  include Middleware

  def configure(&block)
    instance_eval(&block) if block
  end

  def config
    @config ||= RecursiveOpenStruct.new
  end

  # Jets' the default config/application.rb is loaded,
  # then the project's config/application.rb is loaded.
  def load_configs
    require File.expand_path("../default/application.rb", __FILE__)
    app_config = "#{Jets.root}config/application.rb"
    require app_config if File.exist?(app_config)
    set_aliases!
    normalize_env_vars!
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
    # IE: With env_extra: project-dev-1
    #     Without env_extra: project-dev
    config.short_env = ENV_MAP[Jets.env.to_sym] || Jets.env
    config.project_namespace = [config.project_name, config.short_env, config.env_extra].compact.join('-')
    # table_namespace does not have the env_extra, more common case desired.
    config.table_namespace = [config.project_name, config.short_env].compact.join('-')

    # env_extra can be also be set with JETS_ENV_EXTRA.
    # config.env_extra takes higher precedence.
    if ENV['JETS_ENV_EXTRA'] and !config.env_extra
      config.env_extra = ENV['JETS_ENV_EXTRA']
    end
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

end
