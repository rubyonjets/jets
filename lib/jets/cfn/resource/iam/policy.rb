module Jets::Cfn::Resource::Iam
  class Policy < Jets::Cfn::Base
    def initialize(role)
      @role = role
    end
    delegate :policy_document, :policy_name, :role_logical_id, :replacements, to: :@role

    def policy_logical_id
      role_logical_id.sub(/Role$/, "Policy")
    end

    def definition
      logical_id = policy_logical_id

      # Do not assign pretty role_name because long controller names might hit the 64-char
      # limit. Also, IAM roles are global, so assigning role names prevents cross region deploys.
      definition = {
        logical_id => {
          Type: "AWS::IAM::Policy",
          Properties: {
            Roles: [Ref: role_logical_id.camelize],
            PolicyName: "#{policy_name[0..127]}", # required, limited to 128-chars
            PolicyDocument: policy_document,
          }
        }
      }

      definition
    end
  end
end
