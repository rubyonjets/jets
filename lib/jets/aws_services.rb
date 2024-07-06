require "aws-sdk-apigateway"
require "aws-sdk-applicationautoscaling"
require "aws-sdk-cloudformation"
require "aws-sdk-cloudwatchlogs"
require "aws-sdk-codebuild"
require "aws-sdk-dynamodb"
require "aws-sdk-ecs"
require "aws-sdk-lambda"
require "aws-sdk-s3"
require "aws-sdk-sns"
require "aws-sdk-sqs"
require "aws-sdk-ssm"
require "aws-sdk-sts"
require "aws-sdk-wafv2"

require "aws_mfa_secure/ext/aws" # add MFA support

module Jets::AwsServices
  include GlobalMemoist
  include StackStatus

  def apigateway
    Aws::APIGateway::Client.new(aws_options)
  end
  global_memoize :apigateway

  def applicationautoscaling
    Aws::ApplicationAutoScaling::Client.new(aws_options)
  end
  global_memoize :applicationautoscaling

  def lambda_client
    Aws::Lambda::Client.new(aws_options)
  end
  global_memoize :lambda_client
  alias_method :aws_lambda, :lambda_client

  def cfn
    Aws::CloudFormation::Client.new(aws_options)
  end
  global_memoize :cfn

  def codebuild
    Aws::CodeBuild::Client.new(aws_options)
  end
  global_memoize :codebuild

  def dynamodb
    Aws::DynamoDB::Client.new(aws_options)
  end
  global_memoize :dynamodb

  def ecs
    Aws::ECS::Client.new(aws_options)
  end
  global_memoize :codebuild

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

  def ssm
    Aws::SSM::Client.new(aws_options)
  end
  global_memoize :ssm

  def sts
    Aws::STS::Client.new(aws_options)
  end
  global_memoize :sts

  def sqs
    Aws::SQS::Client.new(aws_options)
  end
  global_memoize :sqs

  def wafv2
    Aws::WAFV2::Client.new(aws_options)
  end
  global_memoize :wafv2

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
      log_level: :info
    }
    # See debug logger. Noisy.
    # Example:
    #     D, [2022-12-02T13:18:55.298788 #26182] DEBUG -- : [Aws::APIGateway::Client 200 0.030837 0 retries] get_method(rest_api_id:"mke40eh6l0",resource_id:"zf8w2m",http_method:"GET")
    if ENV["JETS_DEBUG_AWS_SDK"]
      options[:log_level] = :debug
      options[:logger] = Logger.new($stdout)
    end
    # https://docs.aws.amazon.com/sdk-for-ruby/v3/developer-guide/debugging.html to enable http_wire_trace
    # See the HTTP headers and JSON responses. Super noisy.
    if ENV["JETS_DEBUG_AWS_SDK_HTTP_WIRE_TRACE"]
      options[:http_wire_trace] = true
    end
    options
  end
end
