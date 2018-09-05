# Jets::Rule::Base < Jets::Lambda::Functions
# Both Jets::Rule::Base and Jets::Lambda::Functions have Dsl modules included.
# So the Jets::Rule::Dsl overrides some of the Jets::Lambda::Functions behavior.
#
# Implements:
#   default_associated_resource: must return @resources
module Jets::Rule::Dsl
  extend ActiveSupport::Concern

  included do
    class << self
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
        update_properties(scope: scope)
      end

      def config_rule_name(value)
        update_properties(config_rule_name: value)
      end

      def description(value)
        update_properties(description: value)
      end
      alias_method :desc, :description

      def input_parameters(value)
        update_properties(input_parameters: value)
      end

      def maximum_execution_frequency(value)
        update_properties(maximum_execution_frequency: value)
      end

      def source(value)
        update_properties(source: value)
      end

      def default_associated_resource
        config_rule
      end

      def config_rule(props={})
        default_props = {
          config_rule_name: "{config_rule_name}",
          source: {
            owner: "CUSTOM_LAMBDA",
            source_identifier: "{namespace}LambdaFunction.Arn",
            source_details: [
              {
                event_source: "aws.config",
                message_type: "ConfigurationItemChangeNotification"
              },
              {
                event_source: "aws.config",
                message_type: "OversizedConfigurationItemChangeNotification"
              }
            ]
          }
        }
        properties = default_props.deep_merge(props)

        resource("{namespace}ConfigRule" => {
          type: "AWS::Config::ConfigRule",
          properties: properties
        })
        @resources # must return @resoures for update_properties
      end

      def managed_rule(name, props={})
        name = name.to_s

        # Similar logic in Replacer::ConfigRule#config_rule_name
        name_without_rule = self.name.underscore.gsub(/_rule$/,'')
        config_rule_name = "#{name_without_rule}_#{name}".dasherize
        source_identifier = name.upcase

        default_props = {
          config_rule_name: config_rule_name,
          source: {
            owner: "AWS",
            source_identifier: source_identifier,
          }
        }
        properties = default_props.deep_merge(props)
        # The key is to use update_properties to update the current resource and maintain
        # the added properties from the convenience methods like scope and description.
        # At the same time, we do not register the task to all_tasks to avoid creating a Lambda function.
        # Instead we store it in all_managed_rules.
        update_properties(properties)
        definition = @resources.first

        register_managed_rule(name, definition)
      end

      # Creates a task but registers it to all_managed_rules instead of all_tasks
      # because we do not want Lambda functions to be created.
      def register_managed_rule(name, definition)
        # A task object is needed to build {namespace} for later replacing.
        task = Jets::Lambda::Task.new(self.name, name, resources: @resources)

        # TODO: figure out better way for specific replacements for different classes
        name_without_rule = self.name.underscore.gsub(/_rule$/,'')
        config_rule_name = "#{name_without_rule}_#{name}".dasherize
        replacements = task.replacements.merge(config_rule_name: config_rule_name)

        all_managed_rules[name] = { definition: definition, replacements: replacements }
        clear_properties
      end

      # AWS managed rules are not actual Lambda functions and require their own storage.
      def all_managed_rules
        @all_managed_rules ||= ActiveSupport::OrderedHash.new
      end

      def managed_rules
        all_managed_rules.values
      end

      # Override Lambda::Dsl.build? to account of possible managed_rules
      def build?
        !tasks.empty? || !managed_rules.empty?
      end
    end
  end
end
