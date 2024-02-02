# CloudFormation Docs AWS::ApiGateway::Stage: https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-apigateway-stage.html
#
# Example:
#
#   ClientCertificate:
#     Type: "AWS::ApiGateway::Stage"
#     Properties:
#       ClientCertificateId: ~
#       RestApiId: ~
#
module Jets::Cfn::Resource::ApiGateway
  class Stage < Jets::Cfn::Base
    def definition
      {
        Stage: {
          Type: "AWS::ApiGateway::Stage",
          Properties: {
            ClientCertificateId: Jets.config.stage.client_certificate,
            RestApiId: "!Ref RestApi"
          }
        }
      }
    end

    def outputs
      {
        Stage: "!Ref Stage",
      }
    end
  end
end
