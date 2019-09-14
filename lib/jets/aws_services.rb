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
  include AwsSession

  def credentials
    return unless session_from_environment?
    Aws::Credentials.new(
      session_from_environment.credentials.access_key_id,
      session_from_environment.credentials.secret_access_key,
      session_from_environment.credentials.session_token
    )
  end

  def aws_cli_options
    return unless session_from_environment?
    return {region: ENV['AWS_REGION'], credentials: credentials} if ENV['AWS_REGION']
    { credentials: credentials }
  end

  def apigateway
    Aws::APIGateway::Client.new(aws_cli_options)
  end
  global_memoize :apigateway

  def cfn
    Aws::CloudFormation::Client.new(aws_cli_options)
  end
  global_memoize :cfn

  def dynamodb
    Aws::DynamoDB::Client.new(aws_cli_options)
  end
  global_memoize :dynamodb

  def aws_lambda
    Aws::Lambda::Client.new(aws_cli_options)
  end
  global_memoize :aws_lambda

  def logs
    Aws::CloudWatchLogs::Client.new(aws_cli_options)
  end
  global_memoize :logs

  def s3
    Aws::S3::Client.new(aws_cli_options)
  end
  global_memoize :s3

  def s3_resource
    Aws::S3::Resource.new(aws_cli_options)
  end
  global_memoize :s3_resource

  def sns
    Aws::SNS::Client.new(aws_cli_options)
  end
  global_memoize :sns

  def sqs
    Aws::SQS::Client.new(aws_cli_options)
  end
  global_memoize :sqs

  def sts
    sts_client = Aws::STS::Client.new
    return sts_client unless session_from_environment?
    sts_client.assume_role(role_arn: ENV['AWS_ROLE_ARN']) if ENV['AWS_ROLE_ARN']
    sts_client.get_session_token(
      duration_seconds: 900,
      serial_number: ENV['AWS_MFA_SERIAL'],
      token_code: ENV['AWS_MFA_TOKEN']
    ) if mfa_login?
    sts_client
  end
  global_memoize :sts
end
