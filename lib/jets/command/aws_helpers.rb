module Jets
  module Command
    module AwsHelpers # :nodoc:
      extend ActiveSupport::Concern

      include Jets::AwsServices

      def first_run?
        return false if ENV['JETS_TEMPLATES']
        !stack_exists?(Jets::Names.parent_stack_name)
      end

      def find_stack(stack_name)
        resp = cfn.describe_stacks(stack_name: stack_name)
        resp.stacks.first
      rescue Aws::CloudFormation::Errors::ValidationError => e
        # example: Stack with id demo-dev does not exist
        if e.message =~ /Stack with/ && e.message =~ /does not exist/
          nil
        else
          raise
        end
      end
    end
  end
end
