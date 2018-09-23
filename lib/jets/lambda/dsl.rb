require 'active_support/concern'

# Other dsl that rely on this must implement
#
#   default_associated_resource_definition
#
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
      # Main method that registers resources associated with the Lambda function.
      # All resources methods lead here.
      def associated_resources(*definitions)
        if definitions == [nil] # when associated_resources called with no arguments
          @associated_resources || []
        else
          @associated_resources ||= []
          @associated_resources += definitions
          @associated_resources.flatten!
        end
      end
      # User-friendly short resource method. Users will use this.
      alias_method :resource, :associated_resources

      # Properties belonging to the associated resource
      def associated_properties(options={})
        @associated_properties ||= {}
        @associated_properties.deep_merge!(options)
      end
      alias_method :associated_props, :associated_properties

      # meta definition
      def self.define_associated_properties(associated_properties)
        associated_properties.each do |property|
          # Example:
          #   def config_rule_name(value)
          #     associated_properties(config_rule_name: value)
          #   end
          class_eval <<~CODE
            def #{property}(value)
              associated_properties(#{property}: value)
            end
          CODE
        end
      end

      # Loop back through the resources and add a counter to the end of the id
      # to handle multiple events.
      # Then replace @associated_resources entirely
      def add_logical_id_counter
        numbered_resources = []
        n = 1
        @associated_resources.map do |definition|
          logical_id = definition.keys.first
          logical_id = logical_id.sub(/\d+$/,'')
          numbered_resources << { "#{logical_id}#{n}" => definition.values.first }
          n += 1
        end
        @associated_resources = numbered_resources
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

        # At this point we can use the current associated_properties and defined the
        # associated resource with the Lambda function.
        if !associated_properties.empty?
          associated_resources(default_associated_resource_definition(meth))
        end

        # Unsure why but we have to use @associated_resources vs associated_resources
        # associated_resources is always nil
        if @associated_resources && @associated_resources.size > 1
          add_logical_id_counter
        end

        all_tasks[meth] = Jets::Lambda::Task.new(self.name, meth,
          properties: @properties, # lambda function properties
          iam_policy: @iam_policy,
          managed_iam_policy: @managed_iam_policy,
          associated_resources: @associated_resources,
          lang: lang,
          replacements: replacements(meth))

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

      # Meant to be overridden to add more custom replacements based on the app class type
      def replacements(meth)
        {}
      end

      def clear_properties
        @properties = nil
        @iam_policy = nil
        @managed_iam_policy = nil
        @associated_resources = nil
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
    end # end of class << self
  end # end of included

  def self.add_custom_resource_extensions(base)
    base_path = "#{Jets.root}/app/extensions"
    ActiveSupport::Dependencies.autoload_paths += [base_path]

    Dir.glob("#{base_path}/**/*.rb").each do |path|
      next unless File.file?(path)

      class_name = path.sub("#{base_path}/", '').sub(/\.rb/,'').classify
      klass = class_name.constantize # autoload
      base.extend(klass)
    end
  end

  def self.included(base)
    add_custom_resource_extensions(base)
  end
end
