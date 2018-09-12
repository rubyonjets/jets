class Jets::Stack
  class Parameter
    autoload :Dsl, 'jets/stack/parameter/dsl'

    def initialize(*definition)
      @definition = definition
    end

    def register
      self.class.register(*@definition)
    end

    class << self
      def register(*definition)
        @definitions ||= []
        @definitions << definition
      end

      def definitions
        @definitions
      end
    end
  end
end
