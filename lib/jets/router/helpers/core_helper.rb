module Jets::Router::Helpers
  module CoreHelper
    extend ActiveSupport::Concern

    # Used for form_for helper
    def polymorphic_path(record, _)
      url_for(record)
    end

    # override helper delegates to point to jets controller
    # TODO: params is weird
    CONTROLLER_DELEGATES = %w[session response headers]
    CONTROLLER_DELEGATES.each do |meth|
      define_method meth do
        @_jets[:controller].send(meth)
      end
    end

    class_methods do
      def define_helper_method(name)
        define_method(name) do
          @_jets[:controller].send(name)
        end
      end
    end
  end
end
