class Jets::Resource::ApiGateway::Method
  module Authorization
  private
    def authorizer_id
      if @route.authorizer
        logical_id = @route.authorizer_id
      elsif controller_klass.authorizer
        logical_id = controller_klass.authorizer_logical_id_for(@route.action_name)
      end

      "!Ref #{logical_id}" if logical_id
    end

    def authorization_type
      type = @route.authorization_type ||
             controller_klass.authorization_type || # Already handles inheritance via class_attribute, applies controller-wide
             controller_klass.infer_authorization_type_for(@route.action_name) || # Applies specifically to route
             Jets.config.api.authorization_type
      type.to_s.upcase
    end

    def api_key_required?
      api_key_required == true
    end

    def api_key_required
      @route.api_key_required ||
        controller_klass.api_key_required ||
        Jets.config.api.api_key_required
    end

    def authorization_scopes
      if @route.authorization_scopes
        authorization_scopes = @route.authorization_scopes
      elsif controller_klass.authorization_scopes
        authorization_scopes = controller_klass.authorization_scopes
      end
      authorization_scopes
    end
  end
end