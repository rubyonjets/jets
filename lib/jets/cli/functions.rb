class Jets::CLI
  class Functions < Base
    def run
      functions = all
      puts functions.sort
    end

    def all
      functions = []
      nested_stack_resources.each do |resource|
        stack_name = resource.physical_resource_id
        # Custom resource stacks may not have output with function name.
        # So use describe_stack_resources to get the function names.
        resources = cfn.describe_stack_resources(stack_name: stack_name).stack_resources
        resources.each do |r|
          if r.resource_type == "AWS::Lambda::Function"
            functions << r.physical_resource_id if r.physical_resource_id # race condition. can be nil for a brief moment while provisioning
          end
        end
      end
      unless @options[:full]
        functions = functions.map { |f| f.sub("#{Jets.project.namespace}-", "") }
      end
      functions
    end

    def nested_stack_resources
      stack_name = Jets::Names.parent_stack_name
      resp = cfn.describe_stack_resources(stack_name: stack_name)
      resp.stack_resources.select { |r| r.resource_type == "AWS::CloudFormation::Stack" }
    rescue Aws::CloudFormation::Errors::ValidationError => e
      if e.message.include?("does not exist")
        abort "The stack #{stack_name} does not exist.  Have you deployed yet?".color(:red)
      else
        raise
      end
    end
  end
end
