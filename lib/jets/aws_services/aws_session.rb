module Jets::AwsServices
  module AwsSession

    def session_from_environment?
      !!session_from_environment
    end

    def session_from_environment
      return @session if @session
      return @session = env_session if env_session
      return unless mfa_login?
      @session = mfa_login
    end

    def env_session
      return unless ENV['AWS_ACCESS_KEY_ID'] && ENV['AWS_SECRET_ACCESS_KEY'] && ENV['AWS_SESSION_TOKEN']
      OpenStruct.new(
        credentials: OpenStruct.new(
          access_key_id: ENV['AWS_ACCESS_KEY_ID'],
          secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'],
          session_token: ENV['AWS_SESSION_TOKEN']
        )
      )
    end

    def mfa_login?
      ENV['AWS_MFA_SERIAL'] && ENV['AWS_MFA_TOKEN'] && base_credentials
    end

    def mfa_login
      sts_client = Aws::STS::Client.new(options)
      if ENV['AWS_ROLE_ARN']
        session = sts_client.assume_role(
          duration_seconds: 900,
          role_arn: ENV['AWS_ROLE_ARN'],
          role_session_name: ENV['AWS_ROLE_SESSION_NAME'] || "#{ENV['JETS_PROJECT_NAME']}Session",
          serial_number: ENV['AWS_MFA_SERIAL'],
          token_code: ENV['AWS_MFA_TOKEN']
        )
      else
        session = sts_client.get_session_token(
          duration_seconds: 900,
          serial_number: ENV['AWS_MFA_SERIAL'],
          token_code: ENV['AWS_MFA_TOKEN']
        )
      end
      ENV['AWS_SESSION_TOKEN'] = @session.credentials.session_token
      ENV['AWS_SECRET_ACCESS_KEY'] = @session.credentials.secret_access_key
      ENV['AWS_ACCESS_KEY_ID'] = @session.credentials.access_key_id
      ENV['AWS_MFA_TOKEN'] = nil
      session
    end

    def base_credentials
      return @base_credentials if base_credentials
      return unless ENV['AWS_ACCESS_KEY_ID'] && ENV['AWS_SECRET_ACCESS_KEY']
      @base_credentials ||= Aws::Credentials.new(ENV['AWS_ACCESS_KEY_ID'], ENV['AWS_SECRET_ACCESS_KEY'])
    end
  end
end
