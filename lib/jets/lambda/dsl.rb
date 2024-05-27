# Other dsl that rely on this must implement
#
#   default_associated_resource_definition
#
require "dsl_evaluator" # for DslEvaluator.print_code only

module Jets::Lambda::Dsl
  extend ActiveSupport::Concern

  def lambda_functions
    self.class.lambda_functions
  end

  module ClassMethods
    extend Memoist

    def class_properties(options = nil)
      if options
        @class_properties ||= {}
        @class_properties.deep_merge!(options)
      else
        @class_properties || {}
      end
    end
    alias_method :class_props, :class_properties

    def properties(options = {})
      @properties ||= {}
      @properties.deep_merge!(options)
    end
    alias_method :props, :properties

    def class_environment(hash)
      environment = standardize_env(hash)
      class_properties(Environment: environment)
    end
    alias_method :class_env, :class_environment

    def environment(hash)
      environment = standardize_env(hash)
      properties(Environment: environment)
    end
    alias_method :env, :environment

    # Allows user to pass in hash with or without the :variables key.
    def standardize_env(hash)
      return hash if hash.key?(:Variables)

      environment = {}
      environment[:Variables] ||= {}
      environment[:Variables].merge!(hash)
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
      logging_config
      memory_size
      reserved_concurrent_executions
      role
      runtime
      tags
      timeout
      tracing_config
      vpc_config
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
      class_eval <<~CODE, __FILE__, __LINE__ + 1
        def #{property}(value)
          properties(#{property}: value)
        end

        def class_#{property}(value)
          class_properties(#{property}: value)
        end
      CODE
    end

    # Expose the PROPERTIES list so we can access it
    def properties_list
      PROPERTIES
    end

    # More convenience aliases
    alias_method :memory, :memory_size
    alias_method :class_memory, :class_memory_size
    alias_method :desc, :description
    alias_method :class_desc, :class_description
    alias_method :reserved_concurrency, :reserved_concurrent_executions
    alias_method :class_reserved_concurrency, :class_reserved_concurrent_executions

    attr_writer :provisioned_concurrency

    # definitions: one or more definitions
    def iam_policy(*definitions)
      if definitions.empty?
        @iam_policy
      else
        @iam_policy ||= []
        @iam_policy += definitions.flatten
      end
    end

    # definitions: one or more definitions
    def class_iam_policy(*definitions)
      if definitions.empty?
        @class_iam_policy
      else
        @class_iam_policy ||= []
        @class_iam_policy += definitions.flatten
      end
    end

    # definitions: one or more definitions
    def managed_iam_policy(*definitions)
      if definitions.empty?
        @managed_iam_policy
      else
        @managed_iam_policy ||= []
        @managed_iam_policy += definitions.flatten
      end
    end

    # definitions: one or more definitions
    def class_managed_iam_policy(*definitions)
      if definitions.empty?
        @class_managed_iam_policy
      else
        @class_managed_iam_policy ||= []
        @class_managed_iam_policy += definitions.flatten
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
        associated_resource = Jets::Cfn::Resource::Associated.new(definitions)
        associated_resource.multiple_resources = @multiple_resources
        @associated_resources << associated_resource
        @associated_resources.flatten!
      end
    end
    alias_method :associated_resource, :associated_resources
    # Allow user to use `resource` instead of `associated_resource` for a more natural feel
    # User-friendly short resource method. Users will use this.
    alias_method :resource, :associated_resources

    def associated_outputs(outputs = {})
      @associated_outputs ||= []
      @associated_outputs << outputs
    end

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
    def associated_properties(options = {})
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
        class_eval <<~CODE, __FILE__, __LINE__ + 1
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

        logical_id = logical_id.to_s.sub(/\d+$/, "")
        new_definition = {"#{logical_id}#{n}" => attributes}
        numbered_resources << Jets::Cfn::Resource::Associated.new(new_definition)
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
    # interface method
    def depends_on(*stacks)
    end

    def ref(name)
      "!Ref #{name.to_s.camelize}"
    end

    def sub(value)
      "!Sub #{value.to_s.camelize}"
    end

    # meth is a Symbol
    def method_added(meth)
      return if %w[initialize method_missing].include?(meth.to_s)
      return unless public_method_defined?(meth)

      register_definition(meth)
    end

    def register_definition(meth, lang = :ruby)
      # Note: for anonymous classes like for app/functions self.name is ""
      # We adjust the class name when we build the functions later in
      # FunctionContstructor#adjust_definitions.

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

      all_definitions[meth] = Jets::Lambda::Definition.new(name, meth,
        properties: @properties, # lambda function properties
        provisioned_concurrency: @provisioned_concurrency,
        iam_policy: @iam_policy,
        managed_iam_policy: @managed_iam_policy,
        associated_resources: @associated_resources,
        associated_outputs: @associated_outputs,
        lang: lang,
        replacements: replacements(meth))

      # Done storing options, clear out for the next added method.
      clear_properties
      # Important to clear @properties at the end of registering outside of
      # register_definition because register_definition is overridden in Jets::Event::Dsl
      #
      #   Jets::Event::Base < Jets::Lambda::Functions
      #
      # Both Jets::Event::Base and Jets::Lambda::Functions have Dsl modules included.
      # So the Jets::Event::Dsl overrides some of the Jets::Lambda::Dsl behavior.

      true
    end

    # Meant to be overridden to add more custom replacements based on the app class type
    def replacements(meth)
      {}
    end

    def clear_properties
      @properties = nil
      @provisioned_concurrency = nil
      @iam_policy = nil
      @managed_iam_policy = nil
      @associated_resources = nil
      @associated_properties = nil
    end

    # Returns the all definitions for this class with their method names as keys.
    #
    # ==== Returns
    # OrderedHash:: An ordered hash with definitions names as keys and definition
    #               objects as values.
    #
    def all_definitions
      @all_definitions ||= ActiveSupport::OrderedHash.new
    end
    # Do not call all definitions outside this class, instead use: definitions or lambda functions
    private :all_definitions

    # Goes up the class inheritance chain to build the definitions.
    #
    # Example heirarchy:
    #
    #   Jets::Lambda::Functions > Jets::Controller::Base > ApplicationController ...
    #     > PostsController > ChildPostsController
    #
    # Do not include definitions from the direct subclasses of Jets::Lambda::Functions
    # because those classes are abstract.  Dont want those methods to be included.
    def find_all_definitions(options = {})
      public = options[:public].nil? ? true : options[:public]
      klass = self
      direct_subclasses = Jets::Lambda::Functions.subclasses
      lookup = []

      # Go up class inheritance and builds lookup structure in memory
      until direct_subclasses.include?(klass)
        lookup << klass.send(:all_definitions) # one place we want to call private all_definitions method
        klass = klass.superclass
      end
      merged_definitions = ActiveSupport::OrderedHash.new
      # Go back down the class inheritance chain in reverse order and merge the definitions
      lookup.reverse_each do |definitions_hash|
        # definitions_hash is a result of all_definitions. Example: PostsController.all_definitions
        merged_definitions.merge!(definitions_hash)
      end

      # The cfn builders required the right final child class to build the lambda functions correctly.
      merged_definitions.each do |meth, definition|
        # Override the class name for the cfn builders
        definition = definition.clone # do not stomp over current definitions since things are usually looked by reference
        definition.instance_variable_set(:@class_name, name)
        merged_definitions[meth] = definition
      end

      # Methods can be made private with the :private keyword after the method has been defined.
      # To account for this, loop back thorugh all the methods and check if the method is indeed public.
      definitions = ActiveSupport::OrderedHash.new
      merged_definitions.each do |meth, definition|
        if public
          definitions[meth] = definition if definition.public_meth?
        else
          definitions[meth] = definition unless definition.public_meth?
        end
      end
      definitions
    end
    memoize :find_all_definitions

    def all_public_definitions
      find_all_definitions(public: true)
    end

    def all_private_definitions
      find_all_definitions(public: false)
    end

    # Returns the definitions for this class in Array form.
    #
    # ==== Returns
    # Array of definition objects
    #
    def definitions
      all_public_definitions.values
    end

    # The public methods defined in the project app class ulimately become
    # lambda functions.
    #
    # Example return value:
    #   [:index, :new, :create, :show]
    def lambda_functions
      all_public_definitions.keys
    end

    # Used in Jets::Cfn::Builder::Interface#build
    # Overridden in rule/dsl.rb
    def build?
      !definitions.empty?
    end

    # Polymorphic support
    def defpoly(lang, meth)
      register_definition(meth, lang)
    end

    def python(meth)
      defpoly(:python, meth)
    end

    def node(meth)
      defpoly(:node, meth)
    end
  end
end
