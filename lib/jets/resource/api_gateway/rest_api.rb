module Jets::Resource::ApiGateway
  class RestApi < Jets::Resource::Base
    def definition
      {
        rest_api: {
          type: "AWS::ApiGateway::RestApi",
          properties: {
            name: Jets::Naming.gateway_api_name,
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
  end
end