# Implements:
#
#   definition
#   template_filename
#
module Jets::Resource::ChildStack
  class ApiGateway < Base
    def initialize(s3_bucket, options={})
      super
      @page = options[:page]
    end
    
    def definition

      Hash["api_gateway_#{@page}" => {
        type: "AWS::CloudFormation::Stack",
        properties: {
          template_url: template_url,
        }
      }]
    end

    def outputs
      {
        logical_id => "!Ref #{logical_id}",
      }
    end

    def template_filename
      "#{Jets.config.project_namespace}-api-gateway-#{@page}.yml"
    end
  end
end
