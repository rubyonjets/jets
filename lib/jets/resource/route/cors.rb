class Jets::Resource::Route
  class Cors < Jets::Resource::Route
    def attributes
      attributes = {
        "#{resource_logical_id}CorsApiMethod" => {
          type: "AWS::ApiGateway::Method",

          properties: {
            resource_id: "!Ref #{resource_id}",
            rest_api_id: "!Ref RestApi",
            authorization_type: "NONE",
            http_method: "OPTIONS",
            method_responses: [{
              status_code: '200',
              response_parameters: {
                "method.response.header.Access-Control-AllowOrigin": true,
                "method.response.header.Access-Control-AllowHeaders": true,
                "method.response.header.Access-Control-AllowMethods": true,
                "method.response.header.Access-Control-AllowCredentials": true,
              },
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
                response_parameters: {
                  "method.response.header.Access-Control-AllowOrigin": "'#{allow_origin}'",
                  "method.response.header.Access-Control-AllowHeaders": "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,X-Amz-User-Agent'",
                  "method.response.header.Access-Control-AllowMethods": "'OPTIONS,GET'",
                  "method.response.header.Access-Control-AllowCredentials": "'false'",
                },
                response_templates: {
                  "application/json": '',
                },
              }] # closes integration_responses
            } # closes integration
          } # closes properties
        } # closes logical id
      } # closes attributes

      definitions = attributes # to emphasize that its the same thing
      task = Jets::Lambda::Task.new(@route.controller_name, @route.action_name,
               resources: definitions)
      Attributes.new(attributes, task)
    end

    def allow_origin
      if Jets.config.cors == true
        '*'
      elsif
        Jets.config.cors
      end
    end
  end
end
