# add_resource("RestApi", "AWS::ApiGateway::RestApi",
#   Name: Jets::Naming.gateway_api_name
# )
class Jets::Resource
  class RestApi
    include Interface

    def initialize
      @definition = definition
      @replacements = {}
    end

    def definition
      {
        rest_api: {
          type: "AWS::ApiGateway::RestApi",
          properties: {
            name: Jets::Naming.gateway_api_name,
            binary_media_types: '*/*', # TODO: possibly make configurable
          }
        }
      }
    end
  end
end