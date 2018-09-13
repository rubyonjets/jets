class Jets::Stack
  class Main
    module Dsl
      extend ActiveSupport::Concern

      included do
        class << self
          def ref(value)
            "!Ref #{value}"
          end
        end
      end
    end
  end
end
