module Jets::Cfn::Resource::Nested::Api
  class Mapping < Base
    # interface method
    def definition
      {
        ApiMapping: {
          Type: "AWS::CloudFormation::Stack",
          Properties: {
            TemplateURL: template_url,
            Parameters: parameters,
          },
          DependsOn: depends_on,
        }
      }
    end

    def parameters
      p = {
        GemLayer: "!Ref GemLayer",
        IamRole: "!GetAtt IamRole.Arn",
        RestApi: "!GetAtt ApiGateway.Outputs.RestApi",
        S3Bucket: "!Ref S3Bucket",
      }
      p[:DomainName] = "!GetAtt ApiGateway.Outputs.DomainName" if Jets.custom_domain?
      p[:BasePath] = Jets.config.domain.base_path
      p
    end

    def depends_on
      [Jets::Cfn::Resource::ApiGateway::Deployment.logical_id]
    end
  end
end
