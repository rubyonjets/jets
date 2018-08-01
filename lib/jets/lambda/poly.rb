module Jets::Lambda::Poly
  extend ActiveSupport::Concern

  included do
    class << self
      def defpoly(lang, meth)
        register_task(meth, lang)
      end
    end
  end
end
