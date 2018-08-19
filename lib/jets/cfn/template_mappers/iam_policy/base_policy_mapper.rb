# Class that inherits this base class should implement:
#
#   initialize
#   iam_policy
#   logical_id
#   role_name
#
module Jets::Cfn::TemplateMappers::IamPolicy
  class BasePolicyMapper
    extend Memoist

    def properties
      properties = {
        AssumeRolePolicyDocument: {
          Version: "2012-10-17",
          Statement: [{
            Effect: "Allow",
            Principal: {Service: ["lambda.amazonaws.com"]},
            Action: ["sts:AssumeRole"]}
          ]},
        Path: "/"
      }
      properties[:Policies] = [
        PolicyName: iam_policy.policy_name,
        PolicyDocument: iam_policy.policy_document,
      ]
      properties[:RoleName] = role_name
      properties.deep_stringify_keys!
      properties
    end

    def namespace
      Jets.config.project_namespace.underscore
    end
  end
end
