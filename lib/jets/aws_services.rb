require "aws-sdk-cloudformation"
require "aws-sdk-cloudwatchlogs"
require "aws-sdk-lambda"
require "aws-sdk-s3"
require "aws-sdk-sts"

module Jets::AwsServices
  autoload :StackStatus, 'jets/aws_services/stack_status'
  include StackStatus
  extend Memoist

  def cfn
    Aws::CloudFormation::Client.new
  end
  memoize :cfn

  def logs
    Aws::CloudWatchLogs::Client.new
  end
  memoize :logs

  def lambda
    Aws::Lambda::Client.new
  end
  memoize :lambda

  def s3
    Aws::S3::Client.new
  end
  memoize :s3

  def s3_resource
    Aws::S3::Resource.new
  end
  memoize :s3_resource

  def sts
    Aws::STS::Client.new
  end
  memoize :sts
end
