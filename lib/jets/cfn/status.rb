require "cfn_status"

module Jets::Cfn
  class Status < CfnStatus
    extend Memoist

    def initialize(stack_name = Jets::Names.parent_stack_name, options = {})
      super(stack_name, options)
    end

    def failure_message
      puts <<~EOL
        The Jets application failed to deploy. Jets creates a few CloudFormation stacks
        to deploy your application. The logs above show the CloudFormation parent stack
        events. You can go to the CloudFormation console and look for the nested stack
        with the error. The specific nested stack usually shows more detailed information
        and can be used to resolve the issue.
        Example of checking the CloudFormation console:

            https://docs.rubyonjets.com/docs/debug/cloudformation/

      EOL

      show_nested_stack_error
      show_update_update_rollback_failed
    end

    def show_nested_stack_error
      event = find_failed_event
      return unless event
      # When error is not a nested stack return early
      return if event.resource_type != "AWS::CloudFormation::Stack"

      puts "-" * 80
      puts "Here's the nested stack error details: #{event.resource_status_reason}"
      nested_status = self.class.new(event.physical_resource_id, start_index_before_delete: true)
      nested_status.run

      region = Jets.aws.region
      puts <<~EOL
        Here's also the AWS Console link to the failed nested stack:

            https://#{region}.console.aws.amazon.com/cloudformation/home?region=#{region}#/stacks/events?filteringText=&filteringStatus=active&viewNested=true&stackId=#{event.physical_resource_id}

      EOL

      nested_status.events.each do |event|
        if event.resource_status == "CREATE_FAILED" && event.resource_status_reason =~ /already exists in stack/
          debug_tip_already_exist_in_stack(event)
          break
        end
      end
    end

    def show_update_update_rollback_failed
      resp = cfn.describe_stacks(stack_name: @stack_name)
      status = resp.stacks.first.stack_status
      return unless status == "UPDATE_ROLLBACK_FAILED"

      puts <<~EOL
        The parent stack is in UPDATE_ROLLBACK_FAILED status.

        Also, running jets deploy again will attempt a continue-update-rollback operation to try to recover from this state.
        However, if the continue-update-rollback operation fails, you may need to manually resolve the issue.
        You might be able to resolve this with the AWS console continue update rollback
        and skipping the resources that are causing the issue.
      EOL
    end

    def find_failed_event
      cfn_status = self.class.new # fresh instance to get the refreshed events
      cfn_status.refresh_events
      i = cfn_status.start_index
      events = cfn_status.events[0..i].reverse # events are in reverse chronological order
      events.find { |e| e.resource_status =~ /FAILED/ } # first failed event
    end

    # 04:44:53AM CREATE_FAILED AWS::Lambda::Function RecordLambdaFunction rails-demo-dev-temperature_event-record already exists in stack arn:aws:cloudformation:us-west-2:112233445566:stack/rails-demo-dev-TemperatureEvent-1EPIUF1EN4LSQ/0f373000-f229-11ee-9f5f-0a3e531c7fd5
    def debug_tip_already_exist_in_stack(event)
      puts <<~EOL
        The error message indicates that the resource already exists in another stack.

        See: https://docs.rubyonjets.com/docs/debug/resource-already-exists/

      EOL
    end
  end
end
