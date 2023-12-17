require 'cfn_status'

module Jets::Cfn
  class Status < CfnStatus
    extend Memoist

    def initialize(stack_name = Jets::Names.parent_stack_name, options={})
      super(stack_name, options)
    end

    def failure_message!
      puts <<~EOL
        The Jets application failed to deploy. Jets creates a few CloudFormation stacks
        to deploy your application. The logs above show the CloudFormation parent stack
        events. You can go to the CloudFormation console and look for the nested stack
        with the error. The specific nested stack usually shows more detailed information
        and can be used to resolve the issue.
        Example of checking the CloudFormation console:

            https://rubyonjets.com/docs/debugging/cloudformation/

      EOL

      show_nested_stack_error

      exit 1
    end

    def show_nested_stack_error
      event = find_failed_event
      return unless event
      puts "-" * 80
      puts "Here's the nested stack error details: #{event.resource_status_reason}"
      self.class.new(event.physical_resource_id, start_index_before_delete: true).run

      region = Jets.aws.region
      puts <<~EOL
        Here's also the AWS Console link to the failed nested stack:

            https://#{region}.console.aws.amazon.com/cloudformation/home?region=#{region}#/stacks/events?filteringText=&filteringStatus=active&viewNested=true&stackId=#{event.physical_resource_id}

      EOL
    end

    def find_failed_event
      cfn_status = self.class.new # fresh instance to get the refreshed events
      cfn_status.refresh_events
      i = cfn_status.start_index
      events = cfn_status.events[0..i].reverse # events are in reverse chronological order
      events.find { |e| e.resource_status =~ /FAILED/ } # first failed event
    end
  end
end
