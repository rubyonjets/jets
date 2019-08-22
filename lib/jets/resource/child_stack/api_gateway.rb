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
      @required_parameters = options[:required_parameters]
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

      @required_parameters.each do |required_parameter|
        p[required_parameter[:logical_id]] = "!GetAtt #{required_parameter[:location]}"
      end unless @required_parameters.nil?

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
