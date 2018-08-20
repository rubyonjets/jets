module Jets::Lambda::Dsl
  extend ActiveSupport::Concern

  def lambda_functions
    self.class.lambda_functions
  end

  included do
    class << self
      def class_properties(options=nil)
        if options
          @class_properties ||= {}
          @class_properties.deep_merge!(options)
        else
          @class_properties || {}
        end
      end
      alias_method :class_props, :class_properties

      def class_timeout(value)
        class_properties(timeout: value)
      end

      def class_environment(hash)
        environment = {}
        environment[:variables] ||= {}
        environment[:variables].merge!(hash)
        class_properties(environment: environment)
      end
      alias_method :class_env, :class_environment

      def class_memory_size(value)
        class_properties(memory_size: value)
      end
      alias_method :class_memory, :class_memory_size

      def class_role(name)
        class_properties(role: name)
      end

      def class_handler(name)
        class_properties(handler: name)
      end

      # convenience method that set properties
      def timeout(value)
        properties(timeout: value)
      end

      # convenience method that set properties
      def environment(hash)
        environment = {}
        environment[:variables] ||= {}
        environment[:variables].merge!(hash)
        properties(environment: environment)
      end
      alias_method :env, :environment

      # convenience method that set properties
      def memory_size(value)
        properties(memory_size: value)
      end
      alias_method :memory, :memory_size

      def handler(value)
        properties(handler: value)
      end

      def runtime(value)
        properties(runtime: value)
      end

      def properties(options={})
        @properties ||= {}
        @properties.deep_merge!(options)
      end
      alias_method :props, :properties

      # definitions: one more many definitions
      def class_iam_policy(*definitions)
        if definitions.empty?
          @class_iam_policy
        else
          @class_iam_policy = definitions.flatten
        end
      end

      # definitions: one more many definitions
      def iam_policy(*definitions)
        if definitions.empty?
          @iam_policy
        else
          @iam_policy = definitions.flatten
        end
      end

      # meth is a Symbol
      def method_added(meth)
        return if %w[initialize method_missing].include?(meth.to_s)
        return unless public_method_defined?(meth)

        register_task(meth)
      end

      def register_task(meth, lang=:ruby)
        # Note: for anonymous classes like for app/functions self.name is ""
        # We adjust the class name when we build the functions later in
        # FunctionContstructor#adjust_tasks.
        all_tasks[meth] = Jets::Lambda::Task.new(self.name, meth,
          properties: @properties, iam_policy: @iam_policy, lang: lang)

        # Done storing options, clear out for the next added method.
        clear_properties
        # Important to clear @properties at the end of registering outside of
        # register_task because register_task is overridden in Jets::Job::Dsl
        #
        #   Jets::Job::Base < Jets::Lambda::Functions
        #
        # Both Jets::Job::Base and Jets::Lambda::Functions have Dsl modules included.
        # So the Jets::Job::Dsl overrides some of the Jets::Lambda::Dsl behavior.

        true
      end

      def clear_properties
        @properties = nil
        @iam_policy = nil
      end

      # Returns the all tasks for this class with their method names as keys.
      #
      # ==== Returns
      # OrderedHash:: An ordered hash with tasks names as keys and JobTask
      #               objects as values.
      #
      def all_tasks
        @all_tasks ||= ActiveSupport::OrderedHash.new
      end

      # Returns the tasks for this class in Array form.
      #
      # ==== Returns
      # Array of task objects
      #
      def tasks
        all_tasks.values
      end

      # The public methods defined in the project app class ulimately become
      # lambda functions.
      #
      # Example return value:
      #   [:index, :new, :create, :show]
      def lambda_functions
        all_tasks.keys
      end

      # Polymorphic support
      def defpoly(lang, meth)
        register_task(meth, lang)
      end

      def python(meth)
        defpoly(:python, meth)
      end

      def node(meth)
        defpoly(:node, meth)
      end
    end
  end
end
