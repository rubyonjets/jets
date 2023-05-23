module Jets::Cfn::Resource::ApiGateway
  class Authorizer < Jets::Cfn::Base
    def initialize(props={})
      @props = props # associated_properties from dsl.rb
    end

    def definition
      {
        authorizer_logical_id => {
          Type: "AWS::ApiGateway::Authorizer",
          Properties: props,
        }
      }
    end

    def props
      default = {
        # AuthorizerCredentials: '',
        # AuthorizerResultTtlInSeconds: '',
        # AuthType: '',
        # IdentitySource: '', # required
        # IdentityValidationExpression: '',
        # Name: '',
        # ProviderARNs: [],
        RestApiId: '!Ref RestApi', # Required: Yes
        Type: '', # Required: Yes
      }

      unless @props[:Type].to_s.upcase == 'COGNITO_USER_POOLS'
        @props[:AuthorizerUri] = { # Required: Conditional
          "Fn::Join" => ['', [
            'arn:aws:apigateway:',
            "!Ref 'AWS::Region'",
            ':lambda:path/2015-03-31/functions/',
            {"Fn::GetAtt" => ["{namespace}LambdaFunction", "Arn"]},
            '/invocations'
          ]]
        }
      end
      @props[:AuthorizerResultTtlInSeconds] = @props.delete(:ttl) if @props[:ttl] # shorthand

      normalize_type!(@props)
      normalize_identity_source!(@props)
      default.merge(@props)
    end

    def authorizer_logical_id
      "{namespace}Authorizer" # IE: protect_authorizer
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
      type = props[:Type] || :request
      @props[:Type] = type.to_s.upcase
    end

    # Also sets a default if it's not provided
    def normalize_identity_source!(props)
      identity_source = props[:IdentitySource] || Jets.config.api.authorizers.default_token_source
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
      @props[:IdentitySource] = identity_sources.join(',')
    end
  end
end
