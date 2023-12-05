# CloudFormation SNS TopicPolicy docs: https://amzn.to/2SBMq9v
module Jets::Cfn::Resource::Sns
  class TopicPolicy < Jets::Cfn::Base
    def initialize(props={})
      @props = props # associated_properties from dsl.rb
    end

    def definition
      {
        policy_logical_id => {
          Type: "AWS::SNS::TopicPolicy",
          Properties: merged_properties,
        }
      }
    end

    # Do not name this method properties, that is a computed method of `Jets::Cfn::Resource`
    def merged_properties
      {
        PolicyDocument: {
          Version: "2012-10-17",
          Statement: {
            Effect: "Allow",
            Principal: { Service: "s3.amazonaws.com"},
            Action: "sns:Publish",
            Resource: "*", # TODO: figure out good syntax to limit easily
            # Condition:
            #   ArnLike:
            #     aws:SourceArn: arn:aws:s3:::aa-test-95872017
          }
        },
        topics: ["!Ref {namespace}SnsTopic"],
      }.deep_merge(@props)
    end

    def policy_logical_id
      "{namespace}SnsTopicPolicy"
    end
  end
end
