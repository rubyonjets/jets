module Jets::Resource::Iam
  class Policy < Jets::Resource::Base
    def initialize(role)
      @role = role
    end
    delegate :policy_document, :policy_name, :role_logical_id, :replacements, to: :@role

    def policy_logical_id
      role_logical_id.sub(/role$/, "policy")
    end

    def definition
      logical_id = policy_logical_id

      # Do not assign pretty role_name because long controller names might hit the 64-char
      # limit. Also, IAM roles are global, so assigning role names prevents cross region deploys.
      definition = {
        logical_id => {
          type: "AWS::IAM::Policy",
          properties: {
            roles: [Ref: role_logical_id.camelize],
            policy_name: "#{policy_name[0..127]}", # required, limited to 128-chars
            policy_document: policy_document,
          }
        }
      }

      definition
    end
  end
end
