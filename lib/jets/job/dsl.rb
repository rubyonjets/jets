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

      # Override register_function to register a task instead.
      # A Task is a RegisteredFunction with some added DSL methods like like
      # rate and cron.
      def register_function(meth)
        register_task(meth)
      end

      def register_task(meth)
        if @rate || @cron
          functions[meth] = Jets::Job::Task.new(meth,
            class_name: name,
            rate: @rate,
            cron: @cron,
            properties: @properties)
          # done storing options, clear out for the next added method
          @rate, @cron = nil, nil, nil
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

      alias_method :tasks, :functions
      alias_method :all_tasks, :all_functions
    end
  end
end
