# CloudFormation SNS Topic docs: https://amzn.to/2MYbUZc
module Jets::Resource::Sns
  class Topic < Jets::Resource::Base
    def initialize(props={})
      @props = props # associated_properties from dsl.rb
    end

    def definition
      {
        topic_logical_id => {
          type: "AWS::SNS::Topic",
          properties: merged_properties,
        }
      }
    end

    # Do not name this method properties, that is a computed method of `Jets::Resource::Base`
    def merged_properties
      display_name = "{namespace} Topic"[0..99] # limit is 100 chars
      {
        display_name: display_name,
        # Not setting subscription this way but instead with a SNS::Subscription resource so the interface
        # is consistent. Leaving comment in here to remind me and in case decide to change this.
        # subscription: [
        #   endpoint: "!GetAtt {namespace}LambdaFunction.Arn",
        #   protocol: "lambda"
        # ]
      }.deep_merge(@props)
    end

    def topic_logical_id
      "{namespace}_sns_topic"
    end
  end
end