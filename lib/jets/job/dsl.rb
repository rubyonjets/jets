# Jets::Job::Base < Jets::Lambda::Functions
# Both Jets::Job::Base and Jets::Lambda::Functions have Dsl modules included.
# So the Jets::Job::Dsl overrides some of the Jets::Lambda::Functions behavior.
#
# Implements:
#   default_associated_resource
module Jets::Job::Dsl
  extend ActiveSupport::Concern

  included do
    class << self
      def rate(expression)
        update_properties(schedule_expression: "rate(#{expression})")
      end

      def cron(expression)
        update_properties(schedule_expression: "cron(#{expression}")
      end

      def default_associated_resource
        events_rule
      end

      def events_rule(props={})
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
      end
    end
  end
end
