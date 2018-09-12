class Jets::Stack
  module Base
    extend ActiveSupport::Concern

    def initialize(*definition)
      @definition = definition.flatten
    end

    def register
      self.class.register(*@definition)
    end

    def camelize(attributes)
      Jets::Camelizer.transform(attributes)
    end

    included do
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
end
