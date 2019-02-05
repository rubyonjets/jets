module Jets::Resource::ApiGateway
  # Might be weird inheriting from Method because Method has Method#cors also
  # but Cors is essentially a Method class.
  class Cors < Method
    def definition
      {
        cors_logical_id => {
          type: "AWS::ApiGateway::Method",

          properties: {
            resource_id: "!Ref #{resource_id}",
            rest_api_id: "!Ref #{RestApi.logical_id}",
            authorization_type: cors_authorization_type,
            http_method: "OPTIONS",
            method_responses: [{
              status_code: '200',
              response_parameters: response_parameters(true),
              response_models: {},
            }],
            request_parameters: {},
            integration: {
              type: "MOCK",
              request_templates: {
                "application/json": "{statusCode:200}",
              },
              integration_responses: [{
                status_code: '200',
                response_parameters: response_parameters,
                response_templates: {
                  "application/json": '',
                },
              }] # closes integration_responses
            } # closes integration
          } # closes properties
        } # closes logical id
      } # closes definition
    end

    def response_parameters(method_response=false)
      cors_headers.map do |k,v|
        k = "method.response.header.#{k}"
        v = method_response ? true : "'#{v}'" # surround value with single quotes
        [k,v]
      end.to_h
    end

    # Always the pre-flight headers in this case
    def cors_headers
      rack = Jets::Controller::Middleware::Cors.new(Jets.application)
      rack.cors_headers(true)
    end

    def cors_authorization_type
      Jets.config.api.cors_authorization_type || @route.authorization_type || "NONE"
    end

    def cors_logical_id
      "#{resource_logical_id}_cors_api_method"
    end
  end
end
