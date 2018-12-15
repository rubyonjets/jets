module Jets
  class Turbine
    class_attribute :initializers
    class_attribute :on_exceptions

    class << self
      def subclasses
        @subclasses ||= []
      end

      def inherited(base)
        subclasses << base
      end

      def initializer(label, &block)
        self.initializers ||= {}
        self.initializers[label] = block
      end

      def on_exception(label, &block)
        self.on_exceptions ||= {}
        self.on_exceptions[label] = block
      end

      def exception_reporter(label, &block)
        on_exception(label, &block)
      end
    end
  end
end
