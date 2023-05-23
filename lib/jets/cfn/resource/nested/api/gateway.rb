module Jets::Cfn::Resource::Nested::Api
  class Gateway < Base
    # interface method
    def definition
      {
        ApiGateway: {
          Type: "AWS::CloudFormation::Stack",
          Properties: {
            TemplateURL: template_url,
          }
        }
      }
    end
  end
end
