# CloudFormation SNS TopicPolicy docs: https://amzn.to/2SBMq9v
module Jets::Resource::Sns
  class TopicPolicy < Jets::Resource::Base
    def initialize(props={})
      @props = props # associated_properties from dsl.rb
    end

    def definition
      {
        policy_logical_id => {
          type: "AWS::SNS::TopicPolicy",
          properties: merged_properties,
        }
      }
    end

    # Do not name this method properties, that is a computed method of `Jets::Resource::Base`
    def merged_properties
      {
        policy_document: {
          version: "2012-10-17",
          statement: {
            effect: "Allow",
            principal: { service: "s3.amazonaws.com"},
            action: "sns:Publish",
            resource: "*", # TODO: figure out good syntax to limit easily
            # Condition:
            #   ArnLike:
            #     aws:SourceArn: arn:aws:s3:::aa-test-95872017
          }
        },
        topics: ["!Ref {namespace}SnsTopic"],
      }.deep_merge(@props)
    end

    def policy_logical_id
      "{namespace}_sns_topic_policy"
    end
  end
end
