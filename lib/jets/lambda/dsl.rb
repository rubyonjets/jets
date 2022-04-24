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
      extend Memoist

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
        ephemeral_storage
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
          associated_resource = Jets::Resource::Associated.new(definitions)
          associated_resource.multiple_resources = @multiple_resources
          @associated_resources << associated_resource
          @associated_resources.flatten!
        end
      end
      # User-friendly short resource method. Users will use this.
      alias_method :resource, :associated_resources

      # Using this odd way of setting these properties so we can keep the
      # resource(*definitions) signature simple. Using keyword arguments at the end
      # interfere with being able to pass in any keys for the properties hash at the end.
      #
      # TODO: If there's a cleaner way of doing this, let me know.
      def with_fresh_properties(fresh_properties: true, multiple_resources: true)
        @associated_properties = nil if fresh_properties # dont use any current associated_properties
        @multiple_resources = multiple_resources

        yield

        @multiple_resources = false
        @associated_properties = nil if fresh_properties # reset for next definition, since we're defining eagerly
      end

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

      def add_logical_id_counter?
        return false unless @associated_resources
        # Only takes one associated resource with multiple set to true to return false of this check
        return false if @associated_resources.detect { |associated| associated.multiple_resources }
        # Otherwise check if there is more than 1 @associated_resources
        @associated_resources.size > 1
      end

      # Loop back through the resources and add a counter to the end of the id
      # to handle multiple events.
      # Then replace @associated_resources entirely
      def add_logical_id_counter
        numbered_resources = []
        n = 1
        @associated_resources.map do |associated|
          logical_id = associated.logical_id
          attributes = associated.attributes

          logical_id = logical_id.to_s.sub(/\d+$/,'')
          new_definition = { "#{logical_id}#{n}" => attributes }
          numbered_resources << Jets::Resource::Associated.new(new_definition)
          n += 1
        end
        @associated_resources = numbered_resources
      end

      # Examples:
      #
      #   depends_on :custom
      #   depends_on :custom, :alert
      #   depends_on :custom, class_prefix: true
      #   depends_on :custom, :alert, class_prefix: true
      #
      def depends_on(*stacks)
        if stacks == []
          @depends_on
        else
          @depends_on ||= []
          options = stacks.last.is_a?(Hash) ? stacks.pop : {}
          stacks.each do |stack|
            @depends_on << Jets::Stack::Depends::Item.new(stack, options)
          end
        end
      end

      def ref(name)
        "!Ref #{name.to_s.camelize}"
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
        unless associated_properties.empty?
          associated_resources(default_associated_resource_definition(meth))
        end

        # Unsure why but we have to use @associated_resources vs associated_resources
        # associated_resources is always nil
        if add_logical_id_counter?
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
        @associated_properties = nil
      end

      # Returns the all tasks for this class with their method names as keys.
      #
      # ==== Returns
      # OrderedHash:: An ordered hash with tasks names as keys and Task
      #               objects as values.
      #
      def all_tasks
        @all_tasks ||= ActiveSupport::OrderedHash.new
      end
      # Do not call all tasks outside this class, instead use: tasks or lambda functions
      private :all_tasks

      # Goes up the class inheritance chain to build the tasks.
      #
      # Example heirarchy:
      #
      #   Jets::Lambda::Functions > Jets::Controller::Base > ApplicationController ...
      #     > PostsController > ChildPostsController
      #
      # Do not include tasks from the direct subclasses of Jets::Lambda::Functions
      # because those classes are abstract.  Dont want those methods to be included.
      def find_all_tasks(public: true)
        klass = self
        direct_subclasses = Jets::Lambda::Functions.subclasses
        lookup = []

        # Go up class inheritance and builds lookup structure in memory
        until direct_subclasses.include?(klass)
          lookup << klass.send(:all_tasks) # one place we want to call private all_tasks method
          klass = klass.superclass
        end
        merged_tasks = ActiveSupport::OrderedHash.new
        # Go back down the class inheritance chain in reverse order and merge the tasks
        lookup.reverse.each do |tasks_hash|
          # tasks_hash is a result of all_tasks. Example: PostsController.all_tasks
          merged_tasks.merge!(tasks_hash)
        end

        # The cfn builders required the right final child class to build the lambda functions correctly.
        merged_tasks.each do |meth, task|
          # Override the class name for the cfn builders
          task = task.clone # do not stomp over current tasks since things are usually looked by reference
          task.instance_variable_set(:@class_name, self.name)
          merged_tasks[meth] = task
        end

        # Methods can be made private with the :private keyword after the method has been defined.
        # To account for this, loop back thorugh all the methods and check if the method is indeed public.
        tasks = ActiveSupport::OrderedHash.new
        merged_tasks.each do |meth, task|
          if public
            tasks[meth] = task if task.public_meth?
          else
            tasks[meth] = task unless task.public_meth?
          end
        end
        tasks
      end
      memoize :find_all_tasks

      def all_public_tasks
        find_all_tasks(public: true)
      end

      def all_private_tasks
        find_all_tasks(public: false)
      end

      # Returns the tasks for this class in Array form.
      #
      # ==== Returns
      # Array of task objects
      #
      def tasks
        all_public_tasks.values
      end

      # The public methods defined in the project app class ulimately become
      # lambda functions.
      #
      # Example return value:
      #   [:index, :new, :create, :show]
      def lambda_functions
        all_public_tasks.keys
      end

      # Used in Jets::Cfn::Builders::Interface#build
      # Overridden in rule/dsl.rb
      def build?
        !tasks.empty?
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
end
