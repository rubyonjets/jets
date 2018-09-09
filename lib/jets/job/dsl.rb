# Jets::Job::Base < Jets::Lambda::Functions
# Both Jets::Job::Base and Jets::Lambda::Functions have Dsl modules included.
# So the Jets::Job::Dsl overrides some of the Jets::Lambda::Functions behavior.
#
# Implements:
#   default_associated_resource: must return @resources
module Jets::Job::Dsl
  extend ActiveSupport::Concern

  included do
    class << self
      def rate(expression)
        update_properties(schedule_expression: "rate(#{expression})")
      end

      def cron(expression)
        update_properties(schedule_expression: "cron(#{expression})")
      end

      def event_pattern(details={})
        event_rule(event_pattern: details)
        add_descriptions # useful: generic description in the Event Rule console
      end

      def add_descriptions
        numbered_resources = []
        n = 1
        @resources.map do |definition|
          logical_id = definition.keys.first
          attributes = definition.values.first
          attributes[:properties][:description] = "#{self.name} Event Rule #{n}"
          numbered_resources << { "#{logical_id}" => attributes }
          n += 1
        end
        @resources = numbered_resources
      end

      def default_associated_resource
        event_rule
        @resources # must return @resoures for update_properties
      end

      def event_rule(props={})
        default_props = {
          state: "ENABLED",
          targets: [{
            arn: "!GetAtt {namespace}LambdaFunction.Arn",
            id: "{namespace}RuleTarget"
          }]
        }
        properties = default_props.deep_merge(props)

        resource("{namespace}EventsRule" => {
          type: "AWS::Events::Rule",
          properties: properties
        })

        add_logical_id_counter if @resources.size > 1
      end

      # Loop back through the resources and add a counter to the end of the id
      # to handle multiple events.
      # Then replace @resources entirely
      def add_logical_id_counter
        numbered_resources = []
        n = 1
        @resources.map do |definition|
          logical_id = definition.keys.first
          logical_id = logical_id.sub(/\d+$/,'')
          numbered_resources << { "#{logical_id}#{n}" => definition.values.first }
          n += 1
        end
        @resources = numbered_resources
      end
    end
  end
end
