class Jets::Stack
  class Main
    module Dsl
      extend ActiveSupport::Concern

      class_methods do
        def ref(value)
          "!Ref #{value}"
        end
      end
    end
  end
end
