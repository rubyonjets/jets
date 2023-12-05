# CloudFormation SNS Topic docs: https://amzn.to/2MYbUZc
module Jets::Cfn::Resource::Sns
  class Topic < Jets::Cfn::Base
    def initialize(props={})
      @props = props # associated_properties from dsl.rb
    end

    def definition
      {
        topic_logical_id => {
          Type: "AWS::SNS::Topic",
          Properties: merged_properties,
        }
      }
    end

    # Do not name this method properties, that is a computed method of `Jets::Cfn::Resource`
    def merged_properties
      display_name = "{namespace} Topic"[0..99] # limit is 100 chars
      {
        DisplayName: display_name,
        # Not setting subscription this way but instead with a SNS::Subscription resource so the interface
        # is consistent. Leaving comment in here to remind me and in case decide to change this.
        # Subscription: [
        #   Endpoint: "!GetAtt {namespace}LambdaFunction.Arn",
        #   Protocol: "lambda"
        # ]
      }.deep_merge(@props)
    end

    def topic_logical_id
      "{namespace}SnsTopic"
    end
  end
end