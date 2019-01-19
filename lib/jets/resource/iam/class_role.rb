module Jets::Resource::Iam
  class ClassRole < Jets::Resource::Base
    include BaseRoleDefinition

    def initialize(app_class)
      @app_class = app_class.to_s # IE: PostsController, HardJob, Hello, HelloFunction
      @policy_definitions = lookup_iam_policies
      @managed_policy_definitions = lookup_managed_iam_policies
    end

    def role_logical_id
      "{namespace}_iam_role".underscore
    end

    def policy_name
      class_namespace = replacements[:namespace].underscore.dasherize
      "#{Jets.config.project_namespace}-#{class_namespace}-policy" # camelized because used as template value
    end

    def replacements
      {
        namespace: @app_class.gsub('::','').camelize, # camelized because can be used as value
      }
    end

    def policy_document
      # Handles precedence inheritance from the ApplicationRole to the ClassRole
      @policy_definitions += application_role.policy_definitions if inherit?
      super
    end

    def managed_policy_arns
      @managed_policy_definitions += application_role.managed_policy_definitions if inherit?
      super
    end

    # There are 2 types of inheritance: from superclasses and from higher precedence policies.
    # This one manages the inheritance for higher precedence policies.
    def inherit?
      !@policy_definitions.empty? || !@managed_policy_definitions.empty?
    end

    def application_role
      Jets::Resource::Iam::ApplicationRole.new
    end
    memoize :application_role

    # Accounts for inherited class_managed_iam_policy from superclasses
    def lookup_managed_iam_policies
      all_classes.map do |k|
        k.class_managed_iam_policy # class_managed_iam_policy contains definitions
      end.uniq
    end

    # Accounts for inherited class_iam_policies from superclasses
    def lookup_iam_policies
      all_classes.map do |k|
        k.class_iam_policy # class_iam_policy contains definitions
      end.uniq
    end

    # Class heirachry in top to down order
    def all_classes
      klass = @app_class.constantize
      all_classes = []
      while klass != Object
        all_classes << klass
        klass = klass.superclass
      end
      all_classes.reverse
    end
    memoize :all_classes
  end
end