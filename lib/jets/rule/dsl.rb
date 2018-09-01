# Jets::Rule::Base < Jets::Lambda::Functions
# Both Jets::Rule::Base and Jets::Lambda::Functions have Dsl modules included.
# So the Jets::Rule::Dsl overrides some of the Jets::Lambda::Functions behavior.
#
# Implements:
#   default_associated_resource
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
      end

      def clear_properties
        super
        @all_managed_rules = nil
      end

      ## aws managed rules work different enough to merit their own storage

      def all_managed_rules
        @all_managed_rules ||= ActiveSupport::OrderedHash.new
      end

      def managed_rules
        all_managed_rules.values
      end

      def managed_rule(meth)
        all_managed_rules[meth] = Jets::Rule::AwsManagedRule.new(self.name, meth,
          properties: @properties, config_rule: @config_rule)
        clear_properties
        true
      end

      # Override Lambda::Dsl.build? to account of possible managed_rules
      def build?
        !tasks.empty? || !managed_rules.empty?
      end
    end
  end
end
