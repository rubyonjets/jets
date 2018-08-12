# Jets::Job::Base < Jets::Lambda::Functions
# Both Jets::Job::Base and Jets::Lambda::Functions have Dsl modules included.
# So the Jets::Job::Dsl overrides some of the Jets::Lambda::Functions behavior.
module Jets::Job::Dsl
  extend ActiveSupport::Concern

  included do
    class << self
      def rate(expression)
        @rate = expression
      end

      def cron(expression)
        @cron = expression
      end

      # This is a property of the AWS::Events::Rule not the Lambda function
      def state(value)
        @state = value
      end

      # Override register_task.
      # A Job::Task is a Lambda::Task with some added DSL methods like
      # rate and cron.
      def register_task(meth, lang=:ruby)
        if @rate || @cron
          all_tasks[meth] = Jets::Job::Task.new(self.name, meth,
            rate: @rate,
            cron: @cron,
            state: @state,
            properties: @properties,
            lang: lang)
          # done storing options, clear out for the next added method
          @rate, @cron = nil, nil
          true
        else
          task_name = "#{name}##{meth}" # IE: HardJob#dig
          puts "[WARNING] #{task_name} created without a rate or cron expression. " \
            "Add a rate or cron expression above the method definition if you want this method to be scheduled. " \
            "If #{task_name} is not meant to be a scheduled lambda function, you can put the method under after a private keyword to get rid of this warning. " \
            "#{task_name} defined at #{caller[1].inspect}."
          false
        end
      end
    end
  end
end
