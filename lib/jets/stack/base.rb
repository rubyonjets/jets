class Jets::Stack
  module Base
    extend ActiveSupport::Concern

    def initialize(*definition)
      @definition = definition
    end

    def register
      self.class.register(*@definition)
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
