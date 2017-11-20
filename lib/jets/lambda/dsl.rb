module Jets::Lambda::Dsl
  extend ActiveSupport::Concern

  def lambda_functions
    self.class.lambda_functions
  end

  included do
    class << self

      # The public methods defined in the project app class ulimately become
      # lambda functions.
      #
      # Example return value:
      #   [":index", :new, :create, :show]
      def lambda_functions
        all_tasks.map(&:meth)
      end

      # convenience method that set properties
      def timeout(value)
        @properties ||= {}
        @properties[:timeout] = value
      end

      # convenience method that set properties
      def environment(hash)
        @properties ||= {}
        @properties[:environment] ||= {}
        @properties[:environment][:variables] ||= {}
        @properties[:environment][:variables].merge!(hash)
      end
      alias_method :env, :environment

      # convenience method that set properties
      def memory_size(value)
        @properties ||= {}
        @properties[:memory_size] = value
      end
      alias_method :memory, :memory_size

      def properties(options={})
        @properties ||= {}
        @properties = @properties.merge(options)
      end
      alias_method :props, :properties

      # meth is a Symbol
      def method_added(meth)
        return if %w[initialize method_missing].include?(meth.to_s)
        return unless public_method_defined?(meth)

        register_task(meth)
        # Important to clear @properties at the end of registering outside of
        # register_task because register_task is overridden in Jets::Job::Dsl
        #
        # Jets::Job::Base < Jets::Lambda::Function
        # Both Jets::Job::Base and Jets::Lambda::Function have Dsl modules included.
        # So the Jets::Job::Dsl overrides some of the Jets::Lambda::Function behavior.
        clear_properties
      end

      def register_task(meth)
        all_tasks[meth] = Jets::Lambda::Task.new(meth, properties: @properties)
        # done storing options, clear out for the next added method
        true
      end

      def clear_properties
        @properties = nil
      end

      # Returns the all tasks for this class with their method names as keys.
      #
      # ==== Returns
      # OrderedHash:: An ordered hash with tasks names as keys and JobTask
      #               objects as values.
      #
      def all_tasks
        @tasks ||= ActiveSupport::OrderedHash.new
      end

      # Returns the tasks for this Job class in Array form.
      #
      # ==== Returns
      # Array of task objects
      #
      def tasks
        all_tasks.values
      end
    end
  end
end
