module Jets::Cfn::Resource::Nested::Api
  # interface method
  class Methods < Page
    def definition
      {
        "ApiMethods#{@page_number}" =>  {
          Type: "AWS::CloudFormation::Stack",
          Properties: {
            TemplateURL: template_url,
            Parameters: parameters,
          },
        }
      }
    end

    # Read current paged ApiMethods1 template and see what parameters it needs.
    # Then add them to the params hash from Controller Lambda functions outputs
    # Example:
    #
    # api-methods-1.yml:
    #
    #   params["PostsControllerIndexLambdaFunction"] = "!GetAtt UpController.Outputs.PostsControllerIndexLambdaFunction"
    #
    def parameters
      template_path = Jets::Names.api_methods_template_path(@page_number)
      api_methods = Jets::Cfn::Params::Api::Methods.new(template_path: template_path)
      api_methods.params
    end
  end
end
