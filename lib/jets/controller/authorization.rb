class Jets::Controller
  module Authorization
    extend ActiveSupport::Concern

    included do
      class_attribute :auth_type,
                      :auth_to,
                      :auth_options, # for only and except filters
                      :api_key_needed,
                      :authorization_scopes_value
    end

    class_methods do
      def controller_path
        name.sub(/Controller$/, "".freeze).underscore
      end

      def authorization_type(value=nil)
        if !value.nil?
          self.auth_type = value
        else
          self.auth_type
        end
      end

      def authorizer(value=nil, options={})
        if !value.nil?
          self.auth_to = value # IE: main#protect
          self.auth_options = options # IE: only: %w[index] or expect: [:show]
        else
          self.auth_to
        end
      end

      def authorization_scopes(value=nil)
        if !value.nil?
          self.authorization_scopes_value = value
        else
          self.authorization_scopes_value
        end
      end

      def authorizer_metadata
        Jets::Router::Route::Authorizer.metadata(auth_to)
      end

      # Used to add to parameter to controller templates
      def authorizer_id
        Jets::Router::Route::Authorizer.logical_id(auth_to)
      end

      # Used to add to the API::Gateway Method selectively
      def authorizer_logical_id_for(action_name)
        return unless auth_to

        only = auth_options[:only].map(&:to_s) if auth_options && auth_options[:only]
        except = auth_options[:except].map(&:to_s) if auth_options && auth_options[:except]

        if except and !except.include?(action_name)
          logical_id = Jets::Router::Route::Authorizer.logical_id(auth_to)
        end

        # only overrides except
        if only and only.include?(action_name)
          logical_id = Jets::Router::Route::Authorizer.logical_id(auth_to)
        end

        # if both only and except are not set then always set the logical_id
        if !only && !except
          logical_id = Jets::Router::Route::Authorizer.logical_id(auth_to)
        end

        logical_id
      end

      # Autoamtically sets authorization_type for the specific route based on the controller authorizer
      def infer_authorization_type_for(action_name)
        return unless authorizer_logical_id_for(action_name)
        Jets::Authorizer::Base.authorization_type(auth_to)
      end

      def api_key_required(value=nil)
        if !value.nil?
          self.api_key_needed = value
        else
          self.api_key_needed
        end
      end
    end
  end
end
