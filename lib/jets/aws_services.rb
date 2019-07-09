require "aws-sdk-apigateway"
require "aws-sdk-cloudformation"
require "aws-sdk-cloudwatchlogs"
require "aws-sdk-dynamodb"
require "aws-sdk-lambda"
require "aws-sdk-s3"
require "aws-sdk-sts"
# Not used in Jets internally but convenient for shared resources
require "aws-sdk-sns"
require "aws-sdk-sqs"

module Jets::AwsServices
  include GlobalMemoist
  include StackStatus

  def session
    return @session if @session
    return @session = OpenStruct.new(
      credentials: OpenStruct.new(
        access_key_id: ENV['AWS_ACCESS_KEY_ID'],
        secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'],
        session_token: ENV['AWS_SESSION_TOKEN']
      )
    ) if ENV['AWS_ACCESS_KEY_ID'] && ENV['AWS_SECRET_ACCESS_KEY'] && ENV['AWS_SESSION_TOKEN']
    return unless ENV['AWS_MFA_SERIAL'] && ENV['AWS_MFA_TOKEN'] && base_credentials
    sts_client = Aws::STS::Client.new(options)
    @session = sts_client.assume_role(duration_seconds: 900, role_arn: ENV['AWS_ROLE_ARN'], role_session_name: 'nni-aws-sandbox', serial_number: ENV['AWS_MFA_SERIAL'], token_code: ENV['AWS_MFA_TOKEN']) if ENV['AWS_ROLE_ARN']
    ENV['AWS_SESSION_TOKEN'] = @session.credentials.session_token
    ENV['AWS_SECRET_ACCESS_KEY'] = @session.credentials.secret_access_key
    ENV['AWS_ACCESS_KEY_ID'] = @session.credentials.access_key_id
    ENV['AWS_MFA_TOKEN'] = nil
    @session
  end

  def base_credentials
    return unless ENV['AWS_ACCESS_KEY_ID'] && ENV['AWS_SECRET_ACCESS_KEY']
    Aws::Credentials.new(ENV['AWS_ACCESS_KEY_ID'], ENV['AWS_SECRET_ACCESS_KEY'])
  end

  def credentials
    return unless session
    creds = Aws::Credentials.new( session.credentials.access_key_id, session.credentials.secret_access_key, session.credentials.session_token )
  end

  def role_credentials
    session unless @role_credentials
    @role_credentials
  end

  def options
    return {} unless ENV['AWS_REGION'] && base_credentials
    {region: ENV['AWS_REGION'], credentials: base_credentials}
  end

  def session_options
    {region: ENV['AWS_REGION'], credentials: credentials}
  end

  def apigateway
    Aws::APIGateway::Client.new(session_options)
  end
  global_memoize :apigateway

  def cfn
    Aws::CloudFormation::Client.new(session_options)
  end
  global_memoize :cfn

  def dynamodb
    Aws::DynamoDB::Client.new(session_options)
  end
  global_memoize :dynamodb

  def aws_lambda
    Aws::Lambda::Client.new(session_options)
  end
  global_memoize :aws_lambda

  def logs
    Aws::CloudWatchLogs::Client.new(session_options)
  end
  global_memoize :logs

  def s3_options
    {
      region: ENV['AWS_REGION'],
      access_key_id: ENV['AWS_ACCESS_KEY_ID'],
      secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'],
      session_token: ENV['AWS_SESSION_TOKEN']
    }
  end
  global_memoize :s3_options

  def s3
    Aws::S3::Client.new(session_options)
  end
  global_memoize :s3

  def s3_resource
    Aws::S3::Resource.new(session_options)
  end
  global_memoize :s3_resource

  def sns
    Aws::SNS::Client.new(session_options)
  end
  global_memoize :sns

  def sqs
    Aws::SQS::Client.new(session_options)
  end
  global_memoize :sqs

  def sts
    sts_client = Aws::STS::Client.new
    return sts_client unless ENV['AWS_MFA_SERIAL'] && ENV['AWS_MFA_TOKEN']
    sts_client.assume_role(role_arn: ENV['AWS_ROLE_ARN']) if ENV['AWS_ROLE_ARN']
    @session = sts_client.get_session_token( duration_seconds: 900, serial_number: ENV['AWS_MFA_SERIAL'], token_code: ENV['AWS_MFA_TOKEN'])
    sts_client
  end
  global_memoize :sts
end
