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
  autoload :GlobalMemoist, 'jets/aws_services/global_memoist'
  autoload :S3Bucket, 'jets/aws_services/s3_bucket'
  autoload :StackStatus, 'jets/aws_services/stack_status'

  include GlobalMemoist
  include StackStatus

  def apigateway
    Aws::APIGateway::Client.new
  end
  global_memoize :apigateway

  def cfn
    Aws::CloudFormation::Client.new
  end
  global_memoize :cfn

  def dynamodb
    Aws::DynamoDB::Client.new
  end
  global_memoize :dynamodb

  def lambda
    Aws::Lambda::Client.new
  end
  global_memoize :lambda

  def logs
    Aws::CloudWatchLogs::Client.new
  end
  global_memoize :logs

  def s3
    Aws::S3::Client.new
  end
  global_memoize :s3

  def s3_resource
    Aws::S3::Resource.new
  end
  global_memoize :s3_resource

  def sns
    Aws::SNS::Client.new
  end
  global_memoize :sns

  def sqs
    Aws::SQS::Client.new
  end
  global_memoize :sqs

  def sts
    Aws::STS::Client.new
  end
  global_memoize :sts
end
