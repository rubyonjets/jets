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
      end

      def register_function(meth)
        @properties ||= {}
        functions[meth] = Jets::Lambda::RegisteredFunction.new(meth, @properties)
        # done storing options, clear out for the next added method
        @properties = {}
        true
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
