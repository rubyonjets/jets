module Jets::AwsServices
  module StackStatus
    # Only cache if it is true because the initial deploy checks live status until a stack exists.
    @@stack_exists_cache = [] # helps with CloudFormation rate limit
    def stack_exists?(stack_name)
      return false if Jets.env.test?
      return true if ENV["JETS_NO_INTERNET"]
      return true if @@stack_exists_cache.include?(stack_name)

      exist = nil
      begin
        # When the stack does not exist an exception is raised. Example:
        # Aws::CloudFormation::Errors::ValidationError: Stack with id blah does not exist
        cfn.describe_stacks(stack_name: stack_name)
        @@stack_exists_cache << stack_name
        exist = true
      rescue Aws::CloudFormation::Errors::ValidationError => e
        if /does not exist/.match?(e.message)
          exist = false
        elsif e.message.include?("'stackName' failed to satisfy constraint")
          # Example of e.message when describe_stack with invalid stack name
          # "1 validation error detected: Value 'instance_and_route53' at 'stackName' failed to satisfy constraint: Member must satisfy regular expression pattern: [a-zA-Z][-a-zA-Z0-9]*|arn:[-a-zA-Z0-9:/._+]*"
          log.info "Invalid stack name: #{stack_name}"
          log.info "Full error message: #{e.message}"
          exit 1
        else
          raise # re-raise exception  because unsure what other errors can happen
        end
      end
      exist
    end

    def output_value(outputs, key)
      out = outputs.find { |o| o.output_key == key }
      out&.output_value
    end
  end
end
