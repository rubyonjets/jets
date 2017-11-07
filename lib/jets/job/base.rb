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

      def method_added(meth)
        meth = meth.to_s

        return if %w[initialize method_missing].include?(meth)
        return unless public_method_defined?(meth.to_sym)

        create_task(meth)

        self.register_job(self)
      end

      def create_task(meth)
        @rate ||= nil
        @cron ||= nil
        puts "create_task meth #{meth}"
        puts "  @rate #{@rate.inspect}"
        puts "  @cron #{@cron.inspect}"

        if @rate || @cron
          tasks[meth] = Jets::Job::Task.new(meth, rate: @rate, cron: @cron)
          pp tasks
          # done storing options, clear out for the next added method
          @rate, @cron = nil, nil
          true
        else
          full_task_name = "#{name}##{meth.inspect}"
          puts "[WARNING] #{full_task_name} created without a rate or cron expression.. " \
            "Add a rate or cron expression above the method definition if you want this method to be scheduled. " \
            "If #{full_task_name} is not meant to be a scheduled function, then you can make it a private method to get rid of this warning."
            "Invoked from #{caller[1].inspect}."
          false
        end
      end

      def create_command(meth) #:nodoc:
        @usage ||= nil
        @desc ||= nil
        @long_desc ||= nil
        @hide ||= nil

        if @usage && @desc
          base_class = @hide ? Thor::HiddenCommand : Thor::Command
          commands[meth] = base_class.new(meth, @desc, @long_desc, @usage, method_options)
          @usage, @desc, @long_desc, @method_options, @hide = nil
          true
        elsif all_commands[meth] || meth == "method_missing"
          true
        else
          puts "[WARNING] Attempted to create command #{meth.inspect} without usage or description. " \
               "Call desc if you want this method to be available as command or declare it inside a " \
               "no_commands{} block. Invoked from #{caller[1].inspect}."
          false
        end
      end

      # klass: the job class. EasyJob, HardJob, etc.
      def register_job(klass)
        puts "register_job klass #{klass}".colorize(:cyan)
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
        # puts "all_tasks"
        # puts caller[0..2]
        # TODO: dont think I need all this from_superclass logic.
        @all_tasks ||= from_superclass(:all_tasks, ActiveSupport::OrderedHash.new)
        @all_tasks.merge!(tasks)
      end

      # Retrieves a value from superclass. If it reaches the baseclass,
      # returns default.
      def from_superclass(method, default = nil)
        if self == baseclass || !superclass.respond_to?(method, true)
          default
        else
          value = superclass.send(method)

          # Ruby implements `dup` on Object, but raises a `TypeError`
          # if the method is called on immediates. As a result, we
          # don't have a good way to check whether dup will succeed
          # without calling it and rescuing the TypeError.
          begin
            value.dup
          rescue TypeError
            value
          end

        end
      end

      # SIGNATURE: Sets the baseclass. This is where the superclass lookup
      # finishes.
      def baseclass #:nodoc:
      end

    end

  end
end
