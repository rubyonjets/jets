# CloudFormation SNS Subscription docs: https://amzn.to/2SJtN3C
module Jets::Resource::Sns
  class Subscription < Jets::Resource::Base
    def initialize(props={})
      @props = props # associated_properties from dsl.rb
    end

    def definition
      {
        subscription_logical_id => {
          type: "AWS::SNS::Subscription",
          properties: merged_properties,
        }
      }
    end

    # Do not name this method properties, that is a computed method of `Jets::Resource::Base`
    def merged_properties
      {
        endpoint: "!GetAtt {namespace}LambdaFunction.Arn",
        protocol: "lambda",
      }.deep_merge(@props)
    end

    def subscription_logical_id
      "{namespace}_sns_subscription"
    end
  end
end