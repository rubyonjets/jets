# Jets::Job::Base < Jets::Lambda::Functions
# Both Jets::Job::Base and Jets::Lambda::Functions have Dsl modules included.
# So the Jets::Job::Dsl overrides some of the Jets::Lambda::Functions behavior.
#
# Implements:
#
#   default_associated_resource_definition
#
module Jets::Job::Dsl
  extend ActiveSupport::Concern

  included do
    class << self
      # Public: Creates CloudWatch Event Rule
      #
      # expression - The rate expression.
      #
      # Examples
      #
      #   rate("10 minutes")
      #   rate("10 minutes", description: "Hard job")
      #
      def rate(expression, props={})
        schedule_job("rate(#{expression})", props)
      end

      # Public: Creates CloudWatch Event Rule
      #
      # expression - The cron expression.
      #
      # Examples
      #
      #   cron("0 */12 * * ? *")
      #   cron("0 */12 * * ? *", description: "Hard job")
      #
      def cron(expression, props={})
        schedule_job("cron(#{expression})", props)
      end

      # Eager resource definition
      def schedule_job(expression, props={})
        props = props.merge(schedule_expression: expression)
        associated_properties(props)
        associated_resources(event_rule_definition) # add associated resources immediately
        @associated_properties = nil # reset for next definition, since we're defining eagerly
      end

      # Eager resource definition
      def event_pattern(details={}, props={})
        props = props.merge(event_pattern: details)
        associated_properties(props)
        associated_resources(event_rule_definition) # add associated resources immediately
        @associated_properties = nil # reset for next definition, since we're defining eagerly
        add_descriptions # useful: generic description in the Event Rule console
      end

      # Works with eager definitions
      def add_descriptions
        numbered_resources = []
        n = 1
        @associated_resources.map do |definition|
          logical_id = definition.keys.first
          attributes = definition.values.first
          attributes[:properties][:description] ||= "#{self.name} Event Rule #{n}"
          numbered_resources << { "#{logical_id}" => attributes }
          n += 1
        end
        @associated_resources = numbered_resources
      end

      ASSOCIATED_PROPERTIES = %W[
        description
        state
        schedule_expression
      ]
      define_associated_properties(ASSOCIATED_PROPERTIES)

      def default_associated_resource_definition
        event_rule_definition
      end

      def event_rule_definition
        resource = Jets::Resource::Events::Rule.new(associated_properties)
        resource.definition # returns a definition to be added by associated_resources
      end
    end
  end
end
