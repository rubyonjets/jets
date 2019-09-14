# Jets::Rule::Base < Jets::Lambda::Functions
# Both Jets::Rule::Base and Jets::Lambda::Functions have Dsl modules included.
# So the Jets::Rule::Dsl overrides some of the Jets::Lambda::Functions behavior.
#
# Implements:
#
#   default_associated_resource_definition
#
module Jets::Rule::Dsl
  extend ActiveSupport::Concern

  included do
    class << self
      def rule_namespace(value=nil)
        if value.nil?
          @rule_namespace # getter
        else
          @rule_namespace = value # # setter
        end
      end

      # Allows for different types of values. Examples:
      #
      # String: scope "AWS::EC2::SecurityGroup"
      # Array:  scope ["AWS::EC2::SecurityGroup"]
      # Hash:   scope {"ComplianceResourceTypes" => ["AWS::EC2::SecurityGroup"]}
      def scope(value)
        scope = case value
          when String
            {compliance_resource_types: [value]}
          when Array
            {compliance_resource_types: value}
          else # default to hash
            value
          end
        associated_properties(scope: scope)
      end

      # Convenience method that set properties. List based on https://amzn.to/2oSph1P
      # Not all properties are included because some properties are not meant to be set
      # directly. For example, function_name is a calculated setting by Jets.
      ASSOCIATED_PROPERTIES = %W[
        config_rule_name
        description
        input_parameters
        maximum_execution_frequency
      ]
      define_associated_properties(ASSOCIATED_PROPERTIES)
      alias_method :desc, :description

      def default_associated_resource_definition(meth)
        config_rule_definition(meth)
      end

      def config_rule_definition(meth)
        resource = Jets::Resource::Config::ConfigRule.new(self, meth, associated_properties)
        resource.definition # returns a definition to be added by associated_resources
      end

      def managed_rule(name)
        name = name.to_s
        managed_rule = Jets::Resource::Config::ManagedRule.new(self, name, associated_properties)
        resource(managed_rule.definition) # Sets @associated_resources

        # The key to not register the task to all_tasks to avoid creating a Lambda function.
        # Instead we store it in all_managed_rules.
        register_managed_rule(name, managed_rule.definition)
      end

      # Creates a task but registers it to all_managed_rules instead of all_tasks
      # because we do not want Lambda functions to be created.
      def register_managed_rule(name, definition)
        # Mimic task to grab base_replacements, namely namespace.
        # Do not actually use the task to create a Lambda function for managed rules.
        # Only using the task for base_replacements.
        resources = [definition]
        meth = name
        task = Jets::Lambda::Task.new(self.name, meth,
                 resources: resources,
                 replacements: replacements(meth))
        all_managed_rules[name] = { definition: definition, replacements: task.replacements }
        clear_properties
      end

      # Override lambda/dsl.rb to add config_rule_name also
      def replacements(meth)
        name_without_rule = self.name.underscore.gsub(/_rule$/,'')
        config_rule_name = "#{name_without_rule}_#{meth}".dasherize
        {
          config_rule_name: config_rule_name
        }
      end

      # AWS managed rules are not actual Lambda functions and require their own storage.
      def all_managed_rules
        @all_managed_rules ||= ActiveSupport::OrderedHash.new
      end

      def managed_rules
        all_managed_rules.values
      end

      # Override Lambda::Dsl.build? to account for possible managed_rules
      def build?
        !tasks.empty? || !managed_rules.empty?
      end
    end
  end
end
