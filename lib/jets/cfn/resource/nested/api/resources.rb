module Jets::Cfn::Resource::Nested::Api
  class Resources < Page
    # interface method
    def definition
      {
        "ApiResources#{@page_number}" =>  {
          Type: "AWS::CloudFormation::Stack",
          Properties: {
            TemplateURL: template_url,
            Parameters: parameters,
          }
        }
      }
    end

    def parameters
      template_path = Jets::Names.api_resources_template_path(@page_number)
      api_resources = Jets::Cfn::Params::Api::Resources.new(template_path: template_path)
      api_resources.params
    end
  end
end
