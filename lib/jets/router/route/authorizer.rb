class Jets::Router::Route
  module Authorizer
    # IE: main#protect => MainProtectAuthorizer
    def authorizer_id(prefix_class: true)
      return unless authorizer
      logical_id(authorizer, prefix_class: prefix_class)
    end

    # Metadata about the authorizer class that can be used later. Stored in the Authorizer template parameters.
    # In app_class.rb `def controller_params` it is used to build the input parameters for controller templates.
    def authorizer_metadata
      metadata(authorizer)
    end

    def authorizer
      @options[:authorizer]
    end

    def authorization_scopes
      @options[:authorization_scopes]
    end

    def authorization_type
      @options[:authorization_type] || inferred_authorization_type
    end

    def api_key_required
      @options[:api_key_required]
    end

    module ModuleMethods
      def logical_id(authorizer, prefix_class: true)
        klass, meth = authorizer.split("#")
        words = [meth, "authorizer"]
        words.unshift(klass) if prefix_class
        words.join('_').camelize # logical_id
      end

      def metadata(authorizer)
        klass = authorizer.split("#").first
        authorizer_class = "#{klass}_authorizer".camelize
        logical_id = logical_id(authorizer, prefix_class: false)
        # IE: MainAuthorizer.ProtectAuthorizer
        "#{authorizer_class}.#{logical_id}"
      end
    end
    include ModuleMethods # so available as instance methods
    extend ModuleMethods # so also available as module method. IE: Jets::Router::Route::Authorizer.metadata(auth_to)

  private
    def inferred_authorization_type
      return unless authorizer
      Jets::Authorizer::Base.authorization_type(authorizer)
    end

  end
end
