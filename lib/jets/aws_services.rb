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

  def cli_credentials
    return unless env_contains_aws_login_data?
    Aws::Credentials.new(
      env_credentials.access_key_id,
      env_credentials.secret_access_key,
      env_credentials.session_token
    )
  end

  def aws_cli_options
    return {} unless cli_credentials
    return {region: ENV['AWS_REGION'], credentials: cli_credentials} if ENV['AWS_REGION']
    { credentials: cli_credentials }
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
    Aws::STS::Client.new(aws_cli_options)
  end
  global_memoize :sts
end
