require 'json'

# Job public methods get turned into Lambda functions.
class Jets::Job
  class Base < Jets::Lambda::Function
    class << self
      def process(context, event, meth)
        job = new(context, event, meth)
        job.send(meth)
      end

      def perform_now(meth, event, context=nil)
        new(event, context, meth).send(meth)
      end

      def perform_later(meth, event, context=nil)
        function_name = "#{self.to_s.underscore}-#{meth}"
        call = Jets::Call.new(function_name, JSON.dump(event))
        call.run
      end

      def rate(expression)
        @rate = expression
      end

      def cron(expression)
        @cron = expression
      end

      # meth is a Symbol
      def method_added(meth)
        return if %w[initialize method_missing].include?(meth.to_s)
        return unless public_method_defined?(meth)

        register_task(meth)
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
