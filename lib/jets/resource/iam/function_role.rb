module Jets::Resource::Iam
  class FunctionRole < Jets::Resource::Base
    include BaseRoleDefinition

    def initialize(task)
      @task = task
      @policy_definitions = task.iam_policy || [] # iam_policy contains policy definitions
      @managed_policy_definitions = task.managed_iam_policy || [] # managed_iam_policy contains policy definitions
    end

    def role_logical_id
      "{namespace}_iam_role".underscore
    end

    def role_name
      funcion_namespace = replacements[:namespace].underscore.dasherize
      "#{Jets.config.project_namespace}-#{funcion_namespace}-role" # camelized because used as template value
    end

    def replacements
      {
        namespace: "#{@task.class_name.gsub('::','')}#{@task.meth.to_s.camelize}", # camelized because can be used as value
      }
    end
  end
end