class Jets::Stack
  module Base
    def initialize(*definition)
      @definition = definition
    end

    def register
      self.class.register(*@definition)
    end

    # TODO: use ActiveSuport concerns instead
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
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
