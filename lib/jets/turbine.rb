module Jets
  class Turbine
    class_attribute :after_initializers
    class_attribute :initializers
    class_attribute :on_exceptions

    class << self
      def subclasses
        @subclasses ||= []
      end

      def inherited(base)
        subclasses << base
      end

      def after_initializer(label, &block)
        self.after_initializers ||= {}
        self.after_initializers[label] = block
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

      # Make config available in Turbine. Note only available outside of hooks like initializers.
      def config
        Jets.application.config
      end
    end
  end
end
