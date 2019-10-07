module Jets::AwsServices
  module StackStatus
    # Only cache if it is true because the initial deploy checks live status until a stack exists.
    @@stack_exists_cache = [] # helps with CloudFormation rate limit
    def stack_exists?(stack_name)
      return false if Jets.env.test?
      return true if ENV['JETS_BUILD_NO_INTERNET']
      return true if @@stack_exists_cache.include?(stack_name)

      exist = nil
      begin
        # When the stack does not exist an exception is raised. Example:
        # Aws::CloudFormation::Errors::ValidationError: Stack with id blah does not exist
        cfn.describe_stacks(stack_name: stack_name)
        @@stack_exists_cache << stack_name
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
             "Please wait until the stack is ready and try again.".color(:red)
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

    # Lookup output value.
    # Used in Jets::Resource::ApiGateway::RestApi::* andJets::Commands::Url
    def lookup(outputs, key)
      out = outputs.find { |o| o.output_key == key }
      out&.output_value
    end
  end
end
