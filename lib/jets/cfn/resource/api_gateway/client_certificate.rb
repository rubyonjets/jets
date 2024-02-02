# CloudFormation Docs AWS::ApiGateway::ClientCertificate: https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-apigateway-clientcertificate.html
#
# Example:
#
#   ClientCertificate:
#     Type: "AWS::ApiGateway::ClientCertificate"
#     Properties:
#       Description: Jets ClientCertificate
#
module Jets::Cfn::Resource::ApiGateway
  class ClientCertificate < Jets::Cfn::Base
    def definition
      {
        ClientCertificate: {
          Type: "AWS::ApiGateway::ClientCertificate",
          Properties: {
            Description: "Jets ClientCertificate"
          }
        }
      }
    end

    def outputs
      {
        ClientCertificate: "!Ref ClientCertificate",
      }
    end
  end
end
