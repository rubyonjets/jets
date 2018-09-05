module Jets::Resource::Iam
  module BaseRoleDefinition
    def definition
      logical_id = role_logical_id

      definition = {
        logical_id => {
          type: "AWS::IAM::Role",
          properties: {
            role_name: role_name,
            path: "/",
            assume_role_policy_document: {
              version: "2012-10-17",
              statement: [{
                effect: "Allow",
                principal: {service: ["lambda.amazonaws.com"]},
                action: ["sts:AssumeRole"]}
              ]
            }
          }
        }
      }

      definition[logical_id][:properties][:policies] = [
        policy_name: "#{role_name}-policy",
        policy_document: policy_document,
      ] unless policy_document['Statement'].empty?

      unless managed_policy_arns.empty?
        definition[logical_id][:properties][:managed_policy_arns] = managed_policy_arns
      end

      definition
    end

    def policy_document
      PolicyDocument.new(@policy_definitions).policy_document
    end

    def managed_policy_arns
      ManagedPolicy.new(@managed_policy_definitions).arns
    end
  end
end