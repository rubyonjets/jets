# Other dsl that rely on this must implement
#   default_associated_resource: must return @resources
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

      def properties(options={})
        @properties ||= {}
        @properties.deep_merge!(options)
      end
      alias_method :props, :properties

      def class_environment(hash)
        environment = standardize_env(hash)
        class_properties(environment: environment)
      end
      alias_method :class_env, :class_environment

      def environment(hash)
        environment = standardize_env(hash)
        properties(environment: environment)
      end
      alias_method :env, :environment

      # Allows user to pass in hash with or without the :variables key.
      def standardize_env(hash)
        return hash if hash.key?(:variables)

        environment = {}
        environment[:variables] ||= {}
        environment[:variables].merge!(hash)
        environment
      end

      # Convenience method that set properties. List based on https://amzn.to/2oSph1P
      # Not all properites are included because some properties are not meant to be set
      # directly. For example, function_name is a calculated setting by Jets.
      PROPERTIES = %W[
        dead_letter_config
        description
        handler
        kms_key_arn
        memory_size
        reserved_concurrent_executions
        role
        runtime
        timeout
        tracing_config
        vpc_config
        tags
      ]
      PROPERTIES.each do |property|
        # Example:
        #   def timeout(value)
        #     properties(timeout: value)
        #   end
        #
        #   def class_timeout(value)
        #     class_properties(timeout: value)
        #   end
        class_eval <<~CODE
          def #{property}(value)
            properties(#{property}: value)
          end

          def class_#{property}(value)
            class_properties(#{property}: value)
          end
        CODE
      end
      # More convenience aliases
      alias_method :memory, :memory_size
      alias_method :class_memory, :class_memory_size
      alias_method :desc, :description
      alias_method :class_desc, :class_description

      # definitions: one or more definitions
      def iam_policy(*definitions)
        if definitions.empty?
          @iam_policy
        else
          @iam_policy = definitions.flatten
        end
      end

      # definitions: one or more definitions
      def class_iam_policy(*definitions)
        if definitions.empty?
          @class_iam_policy
        else
          @class_iam_policy = definitions.flatten
        end
      end

      # definitions: one or more definitions
      def managed_iam_policy(*definitions)
        if definitions.empty?
          @managed_iam_policy
        else
          @managed_iam_policy = definitions.flatten
        end
      end

      # definitions: one or more definitions
      def class_managed_iam_policy(*definitions)
        if definitions.empty?
          @class_managed_iam_policy
        else
          @class_managed_iam_policy = definitions.flatten
        end
      end

      def build_class_iam?
        !!(class_iam_policy || class_managed_iam_policy)
      end

      #############################
      # Main methood that registers resources associated with the Lambda function.
      # All resources methods lead here.
      def resources(*definitions)
        if definitions == [nil] # when resources called with no arguments
          @resources || []
        else
          @resources ||= []
          @resources += definitions
          @resources.flatten!
        end
      end
      alias_method :resource, :resources

      # Main method that the convenience methods call for to create resources associated
      # with the Lambda function. References the first resource and updates it inplace.
      # Useful for associated resources that are meant to be declare and associated
      # with only one Lambda function. Example:
      #
      #   Config Rule <=> Lambda function is 1-to-1
      #
      # Note: This methods calls default_associated_resource. The inheriting DSL class
      # must implement default_associated_resource. The default_associated_resource should
      # wrap another method that is nicely name so that the nicely name method is
      # available in the DSL. Example:
      #
      #   def default_associated_resource
      #     config_rule
      #   end
      #
      def update_properties(values={})
        @resources ||= default_associated_resource
        definition = @resources.first # singleton
        attributes = definition.values.first
        attributes[:properties].merge!(values)
        @resources
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
          resources: @resources, # associated resources
          properties: @properties, # lambda function properties
          iam_policy: @iam_policy,
          managed_iam_policy: @managed_iam_policy,
          lang: lang)

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
        @resources = nil
        @properties = nil
        @iam_policy = nil
        @managed_iam_policy = nil
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

      # Used in Jets::Cfn::Builders::Interface#build
      # Overridden in rule/dsl.rb
      def build?
        !tasks.empty?
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
