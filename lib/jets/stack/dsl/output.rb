module Jets::Stack::Dsl
  module Output
    extend ActiveSupport::Concern

    class_methods do
      def output(*definition)
        {}
      end
    end
  end
end
