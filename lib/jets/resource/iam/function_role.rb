module Jets::Resource::Iam
  class FunctionRole < Jets::Resource::Base
    include BaseRoleDefinition

    def initialize(task)
      @task = task
      @policy_definitions = task.iam_policy || [] # iam_policy contains policy definitions
      @managed_policy_definitions = task.managed_iam_policy || [] # managed_iam_policy contains policy definitions
    end

    def role_logical_id
      "{namespace}IamRole"
    end

    def role_name
      "{namespace}Role"
    end

    def replacements
      {
        namespace: "#{@task.class_name.gsub('::','')}#{@task.meth.to_s.camelize}",
      }
    end
  end
end