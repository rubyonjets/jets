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
        resource("{namespace}ScheduledEvent" => {
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

      # Override register_task.
      # A Job::Task is a Lambda::Task with some added DSL methods like
      # rate and cron.
      def register_task(meth, lang=:ruby)
        # Always create Job lambda function.
        all_tasks[meth] = Jets::Job::Task.new(self.name, meth,
          resources: @resources,
          properties: @properties,
          lang: lang)

        # Done storing options, clear out for the next added method.
        clear_properties
        true
      end

      def clear_properties
        super
        @resources = nil
      end
    end
  end
end
