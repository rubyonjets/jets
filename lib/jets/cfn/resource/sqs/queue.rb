# CloudFormation SQS Queue docs: https://amzn.to/2MVWk0j
module Jets::Cfn::Resource::Sqs
  class Queue < Jets::Cfn::Base
    def initialize(props={})
      @props = props # associated_properties from dsl.rb
    end

    def definition
      {
        queue_logical_id => {
          Type: "AWS::SQS::Queue",
          Properties: @props,
        }
      }
    end

    def queue_logical_id
      "{namespace}SqsQueue"
    end
  end
end