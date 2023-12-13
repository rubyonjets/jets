module Jets
  class Stack
    include Dsl

    class << self
      extend Memoist

      # Track all command subclasses.
      def subclasses
        @subclasses ||= []
      end

      def inherited(base)
        super
        subclasses << base if base.name
      end

      # Do not name this output, it'll collide with the output DSL method
      def output_value(logical_id)
        puts "lookup logical_id: #{logical_id}"
        outputs.value(logical_id)
      end
      # Keep lookup for backwards compatibility
      alias_method :lookup, :output_value

      def outputs
        Outputs.new(self)
      end
      memoize :outputs
    end
  end
end
