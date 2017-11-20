# Jets::Job::Base < Jets::Lambda::Function
# Both Jets::Job::Base and Jets::Lambda::Function have Dsl modules included.
# So the Jets::Job::Dsl overrides some of the Jets::Lambda::Function behavior.
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

      # Override register_task.
      # A Job::Task is a Lambda::Task with some added DSL methods like
      # rate and cron.
      def register_task(meth)
        if @rate || @cron
          tasks[meth] = Jets::Job::Task.new(meth,
            class_name: name,
            rate: @rate,
            cron: @cron,
            properties: @properties)
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
