# Class that inherits this base class should implement:
#
#   initialize
#   iam_policy
#   managed_iam_policy
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
      ] if iam_policy

      properties[:ManagedPolicyArns] = managed_iam_policy.arns if managed_iam_policy

      properties[:RoleName] = role_name
      properties.deep_stringify_keys!
      properties
    end

    def namespace
      Jets.config.project_namespace.underscore
    end

    # Need to underscore and then classify again for this case:
    #   Jets::PreheatJob_policy => JetsPreheatJobPolicy
    # Or else you we get this:
    #   Jets::PreheatJob_policy => JetsPreheatjobPolicy
    def classify_name(text)
      text.gsub('::','_').underscore.classify
    end
  end
end
