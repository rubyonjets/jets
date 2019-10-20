# Implements:
#
#   definition
#   template_filename
#
module Jets::Resource::ChildStack
  class ApiResource < Base
    def initialize(*)
      super
      @page = @options[:page]
    end

    def definition
      {
        "api_resources_#{@page}" =>  {
          type: "AWS::CloudFormation::Stack",
          # depends_on: "ApiGateway", # CloudFormation seems to be smart enough
          properties: {
            template_url: template_url,
            parameters: parameters,
          }
        }
      }
    end

    def parameters
      params = {}
      # Since dont have all the info required.
      # Read the template back to find the parameters required.
      # Actually might be easier to rationalize this approach.
      template_path = Jets::Naming.api_resources_template_path(@page)
      template = Jets::Cfn::BuiltTemplate.get(template_path)
      template['Parameters'].keys.each do |p|
        case p
        when "RestApi"
          params[p] = "!GetAtt ApiGateway.Outputs.RestApi"
        when "RootResourceId"
          params[p] = "!GetAtt ApiGateway.Outputs.RootResourceId"
        else
          params[p] = "!GetAtt #{api_resource_page(p)}.Outputs.#{p}"
        end
      end
      params
    end

    def api_resource_page(parameter)
      Page.logical_id(parameter)
    end

    def template_filename
      "#{Jets.config.project_namespace}-api-resources-#{@page}.yml"
    end
  end
end
