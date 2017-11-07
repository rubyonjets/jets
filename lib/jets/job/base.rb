require 'json'

class Jets::Job
  class Base < Jets::BaseLambdaFunction
    class << self
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

      # Returns the tasks for this Thor class and all subclasses.
      #
      # ==== Returns
      # OrderedHash:: An ordered hash with tasks names as keys and JobTask
      #               objects as values.
      #
      def all_tasks
        @all_tasks ||= ActiveSupport::OrderedHash.new
        @all_tasks.merge!(tasks)
      end

    end

  end
end
