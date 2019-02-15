# CloudFormation Log Subscription docs: https://amzn.to/2SNiSpr
module Jets::Resource::Logs
  class SubscriptionFilter < Jets::Resource::Base
    def initialize(props={})
      @props = props # associated_properties from dsl.rb
    end

    def definition
      {
        log_logical_id => {
          type: "AWS::Logs::SubscriptionFilter",
          properties: merged_properties,
        }
      }
    end

    # Do not name this method properties, that is a computed method of `Jets::Resource::Base`
    def merged_properties
      {
        destination_arn: "!GetAtt {namespace}LambdaFunction.Arn",
        filter_pattern: "", # matches everything https://amzn.to/2N3b39I
        # log_group_name: string # will be set by log_event
        # role_arn: string # only required for kinensis, we dont use this for Lambda
      }.deep_merge(@props)
    end

    def log_logical_id
      "{namespace}_subscription_filter"
    end
  end
end