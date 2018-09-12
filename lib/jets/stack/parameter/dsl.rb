class Jets::Stack
  class Parameter
    module Dsl
      extend ActiveSupport::Concern

      def parameters
        Parameter.definitions
      end

      included do
        class << self
          def parameter(*definition)
            Parameter.new(*definition).register
          end
        end
      end
    end
  end
end
