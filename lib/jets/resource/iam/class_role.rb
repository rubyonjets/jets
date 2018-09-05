module Jets::Resource::Iam
  class ClassRole < Jets::Resource::Base
    include BaseRoleDefinition

    def initialize(app_class)
      @app_class = app_class.to_s # IE: PostsController, HardJob, Hello, HelloFunction
      @policy_definitions = app_class.class_iam_policy || [] # class_iam_policy contains definitions
      @managed_policy_definitions = app_class.class_managed_iam_policy || [] # class_managed_iam_policy contains definitions
    end

    def role_logical_id
      "{namespace}_iam_role".underscore
    end

    def role_name
      class_namespace = replacements[:namespace].underscore.dasherize
      "#{Jets.config.project_namespace}-#{class_namespace}-role" # camelized because used as template value
    end

    def replacements
      {
        namespace: @app_class.gsub('::','').camelize, # camelized because can be used as value
      }
    end
  end
end