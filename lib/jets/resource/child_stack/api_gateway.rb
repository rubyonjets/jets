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
      @page_range = options[:page_range]
    end
    
    def definition

      properties = {
        template_url: template_url,
      }
      properties["parameters"] = parameters unless @page == 0

      Hash["api_gateway_#{@page}" => {
        type: "AWS::CloudFormation::Stack",
        properties: properties
      }]


    end

    def parameters
      p = {
        RestApi: "!GetAtt ApiGateway0.Outputs.RestApi",
        RootResourceId: "!GetAtt ApiGateway0.Outputs.RootResourceId",
      } 
      p
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
