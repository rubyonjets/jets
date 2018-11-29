class Jets::Resource::Lambda::Function
  module Environment
    def env_properties
      env_vars = Jets::Dotenv.load!(true)
      variables = environment.merge(env_vars)
      {environment: { variables: variables }}
    end

    def environment
      env = Jets.config.environment ? Jets.config.environment.to_h : {}
      env.deep_merge(jets_env)
    end

    # These jets env variables are always included
    def jets_env
      env = {}
      env[:JETS_ENV] = Jets.env.to_s
      env[:JETS_ENV_EXTRA] = Jets.config.env_extra if Jets.config.env_extra
      env[:JETS_STAGE] = Jets::Resource::ApiGateway::Deployment.stage_name
      env
    end
  end
end
