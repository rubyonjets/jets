module Jets::Resource::ApiGateway
  class Authorizer < Jets::Resource::Base
    def initialize(props={})
      @props = props # associated_properties from dsl.rb
    end

    def definition
      {
        authorizer_logical_id => {
          type: "AWS::ApiGateway::Authorizer",
          properties: props,
        }
      }
    end

    def props
      default = {
        # authorizer_credentials: '',
        # authorizer_result_ttl_in_seconds: '',
        # auth_type: '',
        # identity_source: '', # required
        # identity_validation_expression: '',
        # name: '',
        # provider_arns: [],
        rest_api_id: '!Ref RestApi', # Required: Yes
        type: '', # Required: Yes
      }

      unless @props[:type].to_s.upcase == 'COGNITO_USER_POOLS'
        @props[:authorizer_uri] = { # Required: Conditional
          "Fn::Join" => ['', [
            'arn:aws:apigateway:',
            "!Ref 'AWS::Region'",
            ':lambda:path/2015-03-31/functions/',
            {"Fn::GetAtt" => ["{namespace}LambdaFunction", "Arn"]},
            '/invocations'
          ]]
        }
      end
      @props[:authorizer_result_ttl_in_seconds] = @props.delete(:ttl) if @props[:ttl]

      normalize_type!(@props)
      normalize_identity_source!(@props)
      default.merge(@props)
    end

    def authorizer_logical_id
      "{namespace}_authorizer" # IE: protect_authorizer
    end

    def outputs
      # IE: ProtectAuthorizer: !Ref ProtectAuthorizer
      {
        logical_id => "!Ref #{logical_id}",
      }
    end

  private
    # Also sets a default if it's not provided
    def normalize_type!(props)
      type = props[:type] || :request
      @props[:type] = type.to_s.upcase
    end

    # Also sets a default if it's not provided
    def normalize_identity_source!(props)
      identity_source = props[:identity_source] || Jets.config.api.authorizers.default_token_source
      # request authorizer type can have multiple identity sources.
      # token authorizer type has only one identity source.
      # We handle both cases.
      identity_sources = identity_source.split(',') # to handle multipe
      identity_sources.map! do |source|
        if source.include?(".") # if '.' is detected assume full identify source provided
          source
        else
          "method.request.header.#{source}" # convention
        end
      end
      @props[:identity_source] = identity_sources.join(',')
    end
  end
end
