# Implements:
#
#   definition
#   template_filename
#
module Jets::Resource::ChildStack
  class ApiGateway < Base
    def definition
      {
        api_gateway: {
          type: "AWS::CloudFormation::Stack",
          properties: {
            template_url: template_url,
          }
        }
      }
    end

    def outputs
      {
        logical_id => "!Ref #{logical_id}",
      }
    end

    def template_filename
      "#{Jets.config.project_namespace}-api-gateway.yml"
    end
  end
end
