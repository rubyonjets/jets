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

require "aws_mfa_secure/ext/aws" # add MFA support

module Jets::AwsServices
  include GlobalMemoist
  include StackStatus

  def apigateway
    Aws::APIGateway::Client.new(aws_options)
  end
  global_memoize :apigateway

  def cfn
    Aws::CloudFormation::Client.new(aws_options)
  end
  global_memoize :cfn

  def dynamodb
    Aws::DynamoDB::Client.new(aws_options)
  end
  global_memoize :dynamodb

  def aws_lambda
    Aws::Lambda::Client.new(aws_options)
  end
  global_memoize :aws_lambda

  def logs
    Aws::CloudWatchLogs::Client.new(aws_options)
  end
  global_memoize :logs

  def s3
    Aws::S3::Client.new(aws_options)
  end
  global_memoize :s3

  def s3_resource
    Aws::S3::Resource.new(aws_options)
  end
  global_memoize :s3_resource

  def sns
    Aws::SNS::Client.new(aws_options)
  end
  global_memoize :sns

  def sqs
    Aws::SQS::Client.new(aws_options)
  end
  global_memoize :sqs

  def sts
    Aws::STS::Client.new(aws_options)
  end
  global_memoize :sts

  # Override the AWS retry settings with Jets AWS clients.
  #
  # The aws-sdk-core has exponential backup with this formula:
  #
  #   2 ** c.retries * c.config.retry_base_delay
  #
  # So the max delay will be 2 ** 7 * 0.6 = 76.8s
  #
  # Only scoping this to deploy because dont want to affect people's application that use the aws sdk.
  #
  # There is also additional rate backoff logic elsewhere, since this is only scoped to deploys.
  #
  # Useful links:
  #   https://github.com/aws/aws-sdk-ruby/blob/master/gems/aws-sdk-core/lib/aws-sdk-core/plugins/retry_errors.rb
  #   https://docs.aws.amazon.com/apigateway/latest/developerguide/limits.html
  #
  def aws_options
    options = {
      retry_limit: 7, # default: 3
      retry_base_delay: 0.6, # default: 0.3
    }
    options.merge!(
      log_level: :debug,
      logger: Logger.new($stdout),
    ) if ENV['JETS_DEBUG_AWS_SDK']
    options
  end
end
