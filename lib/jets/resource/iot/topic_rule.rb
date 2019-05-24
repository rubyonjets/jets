# CloudFormation AWS::IoT::TopicRule docs: https://amzn.to/2SMBOVm
module Jets::Resource::Iot
  class TopicRule < Jets::Resource::Base
    def initialize(props={})
      @props = props # associated_properties from dsl.rb
    end

    def definition
      {
        topic_logical_id => {
          type: "AWS::IoT::TopicRule",
          properties: merged_properties,
        }
      }
    end

    # Do not name this method properties, that is a computed method of `Jets::Resource::Base`
    def merged_properties
      {
        # required properties
        topic_rule_payload: {
          actions: [{
            lambda: { function_arn: "!GetAtt {namespace}LambdaFunction.Arn" }
          }],
          rule_disabled: 'true',
        }
      }.deep_merge(@props)
    end

    def topic_logical_id
      "{namespace}_iot_topic_rule"
    end
  end
end