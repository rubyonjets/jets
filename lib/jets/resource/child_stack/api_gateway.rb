module Jets::Resource::ChildStack
  class ApiGateway < Jets::Resource::Base
    def initialize(s3_bucket)
      @s3_bucket = s3_bucket
    end

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

    def template_url
      path = File.basename("#{Jets.config.project_namespace}-api-gateway.yml")
      "https://s3.amazonaws.com/#{@s3_bucket}/jets/cfn-templates/#{path}"
    end
  end
end
