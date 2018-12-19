require "aws-sdk-apigateway"
require "aws-sdk-cloudformation"
require "aws-sdk-cloudwatchlogs"
require "aws-sdk-lambda"
require "aws-sdk-s3"
require "aws-sdk-sts"
# Not used in Jets internally but convenient for shared resources
require "aws-sdk-sns"
require "aws-sdk-sqs"

module Jets::AwsServices
  autoload :StackStatus, 'jets/aws_services/stack_status'
  include StackStatus
  extend Memoist

  def apigateway
    Aws::APIGateway::Client.new
  end
  memoize :apigateway

  def cfn
    Aws::CloudFormation::Client.new
  end
  memoize :cfn

  def lambda
    Aws::Lambda::Client.new
  end
  memoize :lambda

  def logs
    Aws::CloudWatchLogs::Client.new
  end
  memoize :logs

  def s3
    Aws::S3::Client.new
  end
  memoize :s3

  def s3_resource
    Aws::S3::Resource.new
  end
  memoize :s3_resource

  def sns
    Aws::SNS::Client.new
  end
  memoize :sns

  def sqs
    Aws::SQS::Client.new
  end
  memoize :sqs

  def sts
    Aws::STS::Client.new
  end
  memoize :sts
end
