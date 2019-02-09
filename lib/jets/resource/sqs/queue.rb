# CloudFormation SQS Queue docs: https://amzn.to/2MVWk0j
module Jets::Resource::Sqs
  class Queue < Jets::Resource::Base
    def initialize(props={})
      @props = props # associated_properties from dsl.rb
    end

    def definition
      {
        queue_logical_id => {
          type: "AWS::SQS::Queue",
          properties: @props,
        }
      }
    end

    def queue_logical_id
      "{namespace}_sqs_queue"
    end
  end
end