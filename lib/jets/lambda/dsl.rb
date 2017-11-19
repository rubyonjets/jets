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
        all_functions.map(&:meth)
      end

      # convenience method
      def timeout(value)
        @properties ||= {}
        @properties[:timeout] = value
      end

      def properties(options={})
        @properties ||= {}
        @properties = @properties.merge(options)
      end

      # meth is a Symbol
      def method_added(meth)
        return if %w[initialize method_missing].include?(meth.to_s)
        return unless public_method_defined?(meth)

        register_function(meth)
        # Important to clear @properties at the end of registering. Doing this
        # here because register_function is overridden in Jets::Job::Dsl
        #
        # Jets::Job::Base < Jets::Lambda::Function
        # Both Jets::Job::Base and Jets::Lambda::Function have Dsl modules included.
        # So the Jets::Job::Dsl overrides some of the Jets::Lambda::Function behavior.
        clear_properties
      end

      def register_function(meth)
        functions[meth] = Jets::Lambda::RegisteredFunction.new(meth, properties: @properties)
        # done storing options, clear out for the next added method
        true
      end

      def clear_properties
        @properties = nil
      end

      # Returns the functions for this Job class.
      #
      # ==== Returns
      # OrderedHash:: An ordered hash with functions names as keys and JobTask
      #               objects as values.
      #
      def functions
        @functions ||= ActiveSupport::OrderedHash.new
      end

      # Returns the functions for this Job class.
      #
      # ==== Returns
      # Array of function objects
      #
      def all_functions
        functions.values
      end
    end
  end
end
