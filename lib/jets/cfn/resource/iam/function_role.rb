module Jets::Cfn::Resource::Iam
  class FunctionRole < Jets::Cfn::Base
    include BaseRoleDefinition

    def initialize(task)
      @task = task
      @policy_definitions = task.iam_policy || [] # iam_policy contains policy definitions
      @managed_policy_definitions = task.managed_iam_policy || [] # managed_iam_policy contains policy definitions
    end

    def role_logical_id
      "{namespace}IamRole"
    end

    def policy_name
      funcion_namespace = replacements[:namespace].underscore.dasherize
      "#{Jets.project_namespace}-#{funcion_namespace}-policy" # camelized because used as template value
    end

    def replacements
      {
        namespace: "#{@task.class_name.gsub('::','')}#{@task.meth.to_s.camelize}", # camelized because can be used as value
      }
    end

    def policy_document
      if inherit?
        @policy_definitions += class_role.policy_definitions + application_role.policy_definitions
      end
      super
    end

    def managed_policy_arns
      if inherit?
        @managed_policy_definitions += class_role.managed_policy_definitions + application_role.managed_policy_definitions
      end
      super
    end

    def inherit?
      !@policy_definitions.empty? || !@managed_policy_definitions.empty?
    end

    def class_role
      Jets::Cfn::Resource::Iam::ClassRole.new(@task.class_name.constantize)
    end
    memoize :class_role

    def application_role
      Jets::Cfn::Resource::Iam::ApplicationRole.new
    end
    memoize :application_role
  end
end