module Jets::Stack::Dsl
  module Parameter
    extend ActiveSupport::Concern

    class_methods do
      def parameter(*definition)
        {}
      end
    end
  end
end
