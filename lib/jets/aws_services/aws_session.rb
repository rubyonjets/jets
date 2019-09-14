module Jets::AwsServices
  module AwsSession

    def env_credentials
      return @session&.credentials if @session&.credentials
      if aws_session_keys?
        @session = env_session
      elsif mfa_login_keys?
        @session = mfa_login
      end
      @session&.credentials
    end

    def aws_session_keys?
      ENV['AWS_ACCESS_KEY_ID'] && ENV['AWS_SECRET_ACCESS_KEY'] && ENV['AWS_SESSION_TOKEN']
    end

    def mfa_login_keys?
      ENV['AWS_MFA_SERIAL'] && ENV['AWS_MFA_TOKEN'] && ENV['AWS_ACCESS_KEY_ID'] && ENV['AWS_SECRET_ACCESS_KEY']
    end

    def env_contains_aws_login_data?
      aws_session_keys? || mfa_login_keys?
    end

    def env_session
      return unless aws_session_keys?
      OpenStruct.new(
        credentials: OpenStruct.new(
          access_key_id: ENV['AWS_ACCESS_KEY_ID'],
          secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'],
          session_token: ENV['AWS_SESSION_TOKEN']
        )
      )
    end

    def mfa_login
      options = ENV['AWS_REGION'] && base_credentials ? {region: ENV['AWS_REGION'], credentials: base_credentials} : {}
      sts_client = Aws::STS::Client.new(options)
      if ENV['AWS_ROLE_ARN']
        @session = sts_client.assume_role(
          duration_seconds: 900,
          role_arn: ENV['AWS_ROLE_ARN'],
          role_session_name: ENV['AWS_ROLE_SESSION_NAME'] || "#{ENV['JETS_PROJECT_NAME']}Session",
          serial_number: ENV['AWS_MFA_SERIAL'],
          token_code: ENV['AWS_MFA_TOKEN']
        )
      else
        @session = sts_client.get_session_token(
          duration_seconds: 900,
          serial_number: ENV['AWS_MFA_SERIAL'],
          token_code: ENV['AWS_MFA_TOKEN']
        )
      end
      ENV['AWS_SESSION_TOKEN'] = @session.credentials.session_token
      ENV['AWS_SECRET_ACCESS_KEY'] = @session.credentials.secret_access_key
      ENV['AWS_ACCESS_KEY_ID'] = @session.credentials.access_key_id
      ENV['AWS_MFA_TOKEN'] = nil
      @session
    end

    def base_credentials
      return @base_credentials if @base_credentials
      return unless ENV['AWS_ACCESS_KEY_ID'] && ENV['AWS_SECRET_ACCESS_KEY']
      @base_credentials ||= Aws::Credentials.new(ENV['AWS_ACCESS_KEY_ID'], ENV['AWS_SECRET_ACCESS_KEY'])
    end
  end
end
