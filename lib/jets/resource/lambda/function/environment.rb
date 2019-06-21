class Jets::Resource::Lambda::Function
  module Environment
    def env_properties
      env_vars = Jets::Dotenv.load!(true)
      variables = environment.merge(env_vars)
      check_reserved_variables!(variables)
      {environment: { variables: variables }}
    end

    def environment
      env = Jets.config.environment ? Jets.config.environment.to_h : {}
      env.deep_merge(jets_env)
    end

    # These jets env variables are special variables that get included to keeps some state
    def jets_env
      env = {}
      env[:JETS_ENV] = Jets.env.to_s
      env[:JETS_ENV_EXTRA] = Jets.config.env_extra if Jets.config.env_extra
      env[:JETS_PROJECT_NAME] = ENV['JETS_PROJECT_NAME'] if ENV['JETS_PROJECT_NAME']
      env[:JETS_STAGE] = Jets::Resource::ApiGateway::Deployment.stage_name
      env[:JETS_AWS_ACCOUNT] = Jets.aws.account
      env
    end

  private
    def check_reserved_variables!(variables)
      found_reserved_vars = variables.keys & reserved_variables
      return if found_reserved_vars.empty?

      puts "You have configured some environment variables that are reserved by AWS Lambda.".color(:red)
      puts found_reserved_vars
      puts "The deployment to AWS Lambda will failed when using reserved variables."
      puts "Please remove these reserved variables. "
      puts "More info: https://docs.aws.amazon.com/lambda/latest/dg/current-supported-versions.html#lambda-environment-variables"
      exit 1
    end

    # https://docs.aws.amazon.com/lambda/latest/dg/current-supported-versions.html#lambda-environment-variables
    def reserved_variables
      %w[
        _HANDLER
        AWS_REGION
        AWS_EXECUTION_ENV
        AWS_LAMBDA_FUNCTION_NAME
        AWS_LAMBDA_FUNCTION_MEMORY_SIZE
        AWS_LAMBDA_FUNCTION_VERSION
        AWS_LAMBDA_LOG_GROUP_NAME
        AWS_LAMBDA_LOG_STREAM_NAME
        AWS_ACCESS_KEY_ID
        AWS_SECRET_ACCESS_KEY
        AWS_SESSION_TOKEN
        TZ
        LAMBDA_TASK_ROOT
        LAMBDA_RUNTIME_DIR
        AWS_LAMBDA_RUNTIME_API
      ]
    end


  end
end
