module Jets
  class Turbine
    class_attribute :initializers
    class_attribute :exception_reporters

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

      def exception_reporter(label, &block)
        self.exception_reporters ||= {}
        self.exception_reporters[label] = block
      end

      # def run_hooks(phase, type, context)
      #   puts "Running hook for #{phase} #{type} #{context}".colorize(:red)
      # end
    end
  end
end
