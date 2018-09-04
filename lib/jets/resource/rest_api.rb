# add_resource("RestApi", "AWS::ApiGateway::RestApi",
#   Name: Jets::Naming.gateway_api_name
# )
class Jets::Resource
  class RestApi
    extend Memoist
    delegate :logical_id, :type, :properties, :attributes,
      to: :resource

    def initialize
      @definition = definition
      @replacements = {}
    end

    def resource
      Jets::Resource.new(definition, replacements)
    end
    memoize :resource

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

    def replacements
      {}
    end
  end
end