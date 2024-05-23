module Jets::Stack::Dsl
  module Resource
    extend ActiveSupport::Concern

    class_methods do
      def resource(*definition)
        {}
      end
    end
  end
end
