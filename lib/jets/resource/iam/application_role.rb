module Jets::Resource::Iam
  class ApplicationRole < Jets::Resource::Base
    include BaseRoleDefinition

    def initialize
      @policy_definitions = Jets.config.iam_policy # config.iam_policy contains definitions
      @policy_definitions = @policy_definitions ? [@policy_definitions].flatten : []

      @managed_policy_definitions = Jets.config.managed_iam_policy # config.managed_iam_policy contains definitions
      @managed_policy_definitions = @managed_policy_definitions ? [@managed_policy_definitions].flatten : []
    end

    def role_logical_id
      "iam_role"
    end

    def policy_name
      "#{Jets.config.project_namespace}-application-policy"
    end

    def outputs
      {
        logical_id => "!Ref #{logical_id}",
      }
    end
  end
end