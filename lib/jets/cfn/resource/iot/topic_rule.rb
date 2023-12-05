# CloudFormation AWS::IoT::TopicRule docs: https://amzn.to/2SMBOVm
module Jets::Cfn::Resource::Iot
  class TopicRule < Jets::Cfn::Base
    def initialize(props={})
      @props = props # associated_properties from dsl.rb
    end

    def definition
      {
        topic_logical_id => {
          Type: "AWS::IoT::TopicRule",
          Properties: merged_properties,
        }
      }
    end

    # Do not name this method properties, that is a computed method of `Jets::Cfn::Resource`
    def merged_properties
      {
        # required properties
        TopicRulePayload: {
          Actions: [{
            Lambda: { FunctionArn: "!GetAtt {namespace}LambdaFunction.Arn" }
          }],
          RuleDisabled: 'false',
        }
      }.deep_merge(@props)
    end

    def topic_logical_id
      "{namespace}IotTopicRule"
    end
  end
end