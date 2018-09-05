require "aws-sdk-s3"
require "aws-sdk-cloudformation"
require "aws-sdk-cloudwatchlogs"
require "aws-sdk-lambda"
require "aws-sdk-sts"

module Jets::AwsServices
  def s3
    @s3 ||= Aws::S3::Client.new
  end

  def s3_resource
    @s3_resource ||= Aws::S3::Resource.new
  end

  def cfn
    @cfn ||= Aws::CloudFormation::Client.new
  end

  def lambda
    @lambda ||= Aws::Lambda::Client.new
  end

  def sts
    @sts ||= Aws::STS::Client.new
  end

  def logs
    @logs ||= Aws::CloudWatchLogs::Client.new
  end

  def stack_exists?(stack_name)
    return false if ENV['TEST']

    exist = nil
    begin
      # When the stack does not exist an exception is raised. Example:
      # Aws::CloudFormation::Errors::ValidationError: Stack with id blah does not exist
      resp = cfn.describe_stacks(stack_name: stack_name)
      exist = true
    rescue Aws::CloudFormation::Errors::ValidationError => e
      if e.message =~ /does not exist/
        exist = false
      elsif e.message.include?("'stackName' failed to satisfy constraint")
        # Example of e.message when describe_stack with invalid stack name
        # "1 validation error detected: Value 'instance_and_route53' at 'stackName' failed to satisfy constraint: Member must satisfy regular expression pattern: [a-zA-Z][-a-zA-Z0-9]*|arn:[-a-zA-Z0-9:/._+]*"
        puts "Invalid stack name: #{stack_name}"
        puts "Full error message: #{e.message}"
        exit 1
      else
        raise # re-raise exception  because unsure what other errors can happen
      end
    end
    exist
  end

  # All CloudFormation states listed here: http://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/using-cfn-describing-stacks.html
  #
  # Returns resp so we can use it to grab data about the stack without calling api again.
  def stack_in_progress?(stack_name)
    return true if !stack_exists?(stack_name)

    # Assumes stack exists
    resp = cfn.describe_stacks(stack_name: stack_name)
    status = resp.stacks[0].stack_status
    if status =~ /_IN_PROGRESS$/
      puts "The '#{stack_name}' stack status is #{status}. " \
           "Please wait until the stack is ready and try again.".colorize(:red)
      exit 0
    elsif resp.stacks[0].outputs.empty? && status != 'ROLLBACK_COMPLETE'
      # This Happens when the miminal stack fails at the very beginning.
      # There is no s3 bucket at all.  User should delete the stack.
      puts "The minimal stack failed to create. Please delete the stack first and try again. " \
      "You can delete the CloudFormation stack or use the `jets delete` command"
      exit 0
    else
      true
    end
  end

end
