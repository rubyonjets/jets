module Jets::Resource::ApiGateway
  class RestApi < Jets::Resource::Base

    def definition
      {
        rest_api: {
          type: "AWS::ApiGateway::RestApi",
          properties: {
            name: Jets::Naming.gateway_api_name,
            endpoint_configuration: {
              types: types
            }
            # binary_media_types: ['*/*'], # TODO: comment out, breaking form post
          }
        }
      }
    end
    
    def outputs
      {
        "RestApi" => "!Ref RestApi",
        "Region" => "!Ref AWS::Region",
        "RootResourceId" => "!GetAtt RestApi.RootResourceId",
      }
    end

    def types
      endpoint_type = Jets.config.api.endpoint_type || 'EDGE'
      [endpoint_type.upcase]
    end
  end
end