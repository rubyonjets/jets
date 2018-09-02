class Jets::Resource::Route
  class Cors < Jets::Resource::Permission
    def attributes
    end

    # Replacements occur for: logical_id
    def attributes
      resource_id = @resource_attributes.logical_id.sub('ApiGatewayResource','CorsApiGatewayResource')

      attributes = {
        "{namespace}CorsApiMethod" => {
          type: "AWS::ApiGateway::Method",

          properties: {
            resource_id: "!Ref #{resource_id}",
            rest_api_id: "!Ref RestApi",
            authorization_type: "NONE",
            http_method: "OPTIONS",
            method_responses: {
              status_code: '200',
              response_parameters: {
                "method.response.header.Access-Control-AllowOrigin": true,
                "method.response.header.Access-Control-AllowHeaders": true,
                "method.response.header.Access-Control-AllowMethods": true,
                "method.response.header.Access-Control-AllowCredentials": true,
              },
              response_models: {},
            },
            request_parameters: {},
            integration: {
              type: "MOCK",
              request_templates: {
                "application/json": "{statusCode:200}",
              },
              integration_responses: {
                status_code: '200',
                response_parameters: {
                  "method.response.header.Access-Control-AllowOrigin": "'*'",
                  "method.response.header.Access-Control-AllowHeaders": "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,X-Amz-User-Agent'",
                  "method.response.header.Access-Control-AllowMethods": "'OPTIONS,GET'",
                  "method.response.header.Access-Control-AllowCredentials": "'false'",
                },
                response_templates: {
                  "application/json": '',
                },
              } # closes integration_responses
            } # closes integration
          } # closes properties
        } # closes logical id
      } # closes attributes

      definitions = attributes # to emphasize that its the same thing
      task = Jets::Lambda::Task.new(@task.class_name, @task.meth,
               resources: definitions)
      Attributes.new(attributes, task)
    end
  end
end
