# Jets::Rule::Base < Jets::Lambda::Functions
# Both Jets::Rule::Base and Jets::Lambda::Functions have Dsl modules included.
# So the Jets::Rule::Dsl overrides some of the Jets::Lambda::Functions behavior.
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
            {"ComplianceResourceTypes" => [value]}
          when Array
            {"ComplianceResourceTypes" => value}
          else # default to hash
            value
          end

        config_rule(scope: scope)
      end

      def config_rule_name(value)
        config_rule(config_rule_name: value)
      end

      def description(value)
        config_rule(description: value)
      end
      alias_method :desc, :description

      def input_parameters(value)
        config_rule(input_parameters: value)
      end

      def maximum_execution_frequency(value)
        config_rule(maximum_execution_frequency: value)
      end

      # not really meant to be used but provided for completeness
      def source(value)
        config_rule(source: value)
      end

      def config_rule(options={})
        @config_rule ||= {}
        @config_rule.deep_merge!(options)
      end

      # Override register_task.
      # Creates instances of Rule::Task instead of a Lambda::Task
      # Also adds the config_rule option that is specific to Rule classes
      def register_task(meth, lang=:ruby)
        all_tasks[meth] = Jets::Rule::Task.new(self.name, meth,
          properties: @properties, config_rule: @config_rule, lang: lang)
        true
      end
    end
  end
end
