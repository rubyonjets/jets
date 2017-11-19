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

      # override register_function to also register a task
      def register_function(meth)
        super
        register_task(meth)
        true
      end

      def register_task(meth)
        @rate ||= nil
        @cron ||= nil

        if @rate || @cron
          tasks[meth] = Jets::Job::Task.new(meth, rate: @rate, cron: @cron, class_name: name)
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

      # Returns the tasks for this Job class.
      #
      # ==== Returns
      # OrderedHash:: An ordered hash with tasks names as keys and JobTask
      #               objects as values.
      #
      def tasks
        @tasks ||= ActiveSupport::OrderedHash.new
      end

      # Returns the tasks for this Job class.
      #
      # ==== Returns
      # Array of task objects
      #
      def all_tasks
        @tasks.values
      end
    end
  end
end
