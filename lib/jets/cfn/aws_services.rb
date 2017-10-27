require "aws-sdk"

module Jets::Cfn::AwsServices
  def cfn
    @cfn ||= Aws::CloudFormation::Client.new
  end

  def stack_exists?(stack_name)
    return false if @options[:noop]

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
end
