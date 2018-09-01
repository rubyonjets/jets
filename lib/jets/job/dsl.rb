# Jets::Job::Base < Jets::Lambda::Functions
# Both Jets::Job::Base and Jets::Lambda::Functions have Dsl modules included.
# So the Jets::Job::Dsl overrides some of the Jets::Lambda::Functions behavior.
module Jets::Job::Dsl
  extend ActiveSupport::Concern

  included do
    class << self
      def rate(expression)
        scheduled_event(expression)
      end

      def cron(expression)
        scheduled_event(expression)
      end

      def scheduled_event(expression)
        resource("{namespace}EventsRule" => {
          type: "AWS::Events::Rule",
          properties: {
            schedule_expression: expression,
            state: "ENABLED",
            targets: [{
              arn: "!GetAtt {namespace}LambdaFunction.Arn",
              id: "{namespace}RuleTarget"
            }]
          }
        })
      end
    end
  end
end
