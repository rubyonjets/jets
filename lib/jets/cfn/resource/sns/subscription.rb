# CloudFormation SNS Subscription docs: https://amzn.to/2SJtN3C
module Jets::Cfn::Resource::Sns
  class Subscription < Jets::Cfn::Base
    def initialize(props={})
      @props = props # associated_properties from dsl.rb
    end

    def definition
      {
        subscription_logical_id => {
          Type: "AWS::SNS::Subscription",
          Properties: merged_properties,
        }
      }
    end

    # Do not name this method properties, that is a computed method of `Jets::Cfn::Resource`
    def merged_properties
      {
        Endpoint: "!GetAtt {namespace}LambdaFunction.Arn",
        Protocol: "lambda",
      }.deep_merge(@props)
    end

    def subscription_logical_id
      "{namespace}SnsSubscription"
    end
  end
end