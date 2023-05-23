# CloudFormation Log Subscription docs: https://amzn.to/2SNiSpr
module Jets::Cfn::Resource::Logs
  class SubscriptionFilter < Jets::Cfn::Base
    def initialize(props={})
      @props = props # associated_properties from dsl.rb
    end

    def definition
      {
        log_logical_id => {
          Type: "AWS::Logs::SubscriptionFilter",
          Properties: merged_properties,
        }
      }
    end

    # Do not name this method properties, that is a computed method of `Jets::Cfn::Resource`
    def merged_properties
      {
        DestinationArn: "!GetAtt {namespace}LambdaFunction.Arn",
        FilterPattern: "", # matches everything https://amzn.to/2N3b39I
        # LogGroupName: string # will be set by log_event
        # RoleArn: string # only required for kinensis, we dont use this for Lambda
      }.deep_merge(@props)
    end

    def log_logical_id
      "{namespace}SubscriptionFilter"
    end
  end
end