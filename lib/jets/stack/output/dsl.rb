class Jets::Stack
  class Output
    module Dsl
      extend ActiveSupport::Concern

      def outputs
        Output.definitions
      end

      included do
        class << self
          def output(*definition)
            Output.new(*definition).register
          end
        end
      end
    end
  end
end
