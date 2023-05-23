# frozen_string_literal: true

require "active_support/descendants_tracker"
require "active_support/inflector"
require "active_support/core_ext/module/introspection"
require "active_support/core_ext/module/delegation"

module Jets
  class Turbine
    extend ActiveSupport::DescendantsTracker
    include Initializable

    ABSTRACT_TURBINES = %w(Jets::Turbine Jets::Engine Jets::Application)

    class << self
      private :new
      delegate :config, to: :instance

      def subclasses
        super.reject(&:abstract_turbine?).sort
      end

      def rake_tasks(&blk)
        register_block_for(:rake_tasks, &blk)
      end

      def console(&blk)
        register_block_for(:load_console, &blk)
      end

      def runner(&blk)
        register_block_for(:runner, &blk)
      end

      def generators(&blk)
        register_block_for(:generators, &blk)
      end

      def server(&blk)
        register_block_for(:server, &blk)
      end

      # Jets specific. The label is no longer used and kept for backwards compatibility.
      # Note it uses the same register_block_for but works a bit differently.
      # See on_exception_blocks method to see how it works.
      def on_exception(label, &blk)
        register_block_for(:on_exception, &blk)
      end

      def abstract_turbine?
        ABSTRACT_TURBINES.include?(name)
      end

      def turbine_name(name = nil)
        @turbine_name = name.to_s if name
        @turbine_name ||= generate_turbine_name(self.name)
      end

      # Since Jets::Turbine cannot be instantiated, any methods that call
      # +instance+ are intended to be called only on subclasses of a Turbine.
      def instance
        @instance ||= new
      end

      # Allows you to configure the turbine. This is the same method seen in
      # Turbine::Configurable, but this module is no longer required for all
      # subclasses of Turbine so we provide the class method here.
      def configure(&block)
        instance.configure(&block)
      end

      def <=>(other) # :nodoc:
        load_index <=> other.load_index
      end

      def inherited(subclass)
        subclass.increment_load_index
        super
      end

      protected
        attr_reader :load_index

        def increment_load_index
          @@load_counter ||= 0
          @load_index = (@@load_counter += 1)
        end

      private
        def generate_turbine_name(string)
          ActiveSupport::Inflector.underscore(string).tr("/", "_")
        end

        def respond_to_missing?(name, _)
          return super if abstract_turbine?

          instance.respond_to?(name) || super
        end

        # If the class method does not have a method, then send the method call
        # to the Turbine instance.
        def method_missing(name, *args, &block)
          if !abstract_turbine? && instance.respond_to?(name)
            instance.public_send(name, *args, &block)
          else
            super
          end
        end
        ruby2_keywords(:method_missing)

        # receives an instance variable identifier, set the variable value if is
        # blank and append given block to value, which will be used later in
        # `#each_registered_block(type, &block)`
        def register_block_for(type, &blk)
          var_name = "@#{type}"
          blocks = instance_variable_defined?(var_name) ? instance_variable_get(var_name) : instance_variable_set(var_name, [])
          blocks << blk if blk
          blocks
        end
    end

    delegate :turbine_name, to: :class

    def initialize # :nodoc:
      if self.class.abstract_turbine?
        raise "#{self.class.name} is abstract, you cannot instantiate it directly."
      end
    end

    def inspect # :nodoc:
      "#<#{self.class.name}>"
    end

    def configure(&block) # :nodoc:
      instance_eval(&block)
    end

    # This is used to create the <tt>config</tt> object on Turbines, an instance of
    # Turbine::Configuration, that is used by Turbines and Application to store
    # related configuration.
    def config
      @config ||= Turbine::Configuration.new
    end

    def turbine_namespace # :nodoc:
      @turbine_namespace ||= self.class.module_parents.detect { |n| n.respond_to?(:turbine_namespace) }
    end

    def on_exception_blocks
      self.class.instance_variable_get(:@on_exception) || []
    end

    protected
      def run_console_blocks(app) # :nodoc:
        each_registered_block(:console) { |block| block.call(app) }
      end

      def run_generators_blocks(app) # :nodoc:
        each_registered_block(:generators) { |block| block.call(app) }
      end

      def run_runner_blocks(app) # :nodoc:
        each_registered_block(:runner) { |block| block.call(app) }
      end

      def run_tasks_blocks(app) # :nodoc:
        extend Rake::DSL
        each_registered_block(:rake_tasks) { |block| instance_exec(app, &block) }
      end

      def run_server_blocks(app) # :nodoc:
        each_registered_block(:server) { |block| block.call(app) }
      end

    private
      # run `&block` in every registered block in `#register_block_for`
      def each_registered_block(type, &block)
        klass = self.class
        while klass.respond_to?(type)
          klass.public_send(type).each(&block)
          klass = klass.superclass
        end
      end
  end
end
