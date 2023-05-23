# CloudFormation Docs AWS::ApiGateway::DomainName: https://amzn.to/2BsrSqo
#
# Example:
#
#   Type: AWS::ApiGateway::BasePathMapping
#   Properties:
#     BasePath: String
#     DomainName: String
#     RestApiId: String
#     Stage: String
#
# Currently unable to add base path mapping in-place with CloudFormation.
# The workaround for this is to do it post deployment with raw API calls outside
# of CloudFormation.  Leaving this around for now in case there's a workaround
# to get this into CloudFormation instead of raw API calls. Some notes:
#   * Also tried to change the domain name of to something like demo-dev-[random].mydomain.com
#   That does not work because the domain name has to match the route53 record exactly.
#
module Jets::Cfn::Resource::ApiGateway::BasePath
  class Mapping < Jets::Cfn::Base
    def definition
      function_logical_id = "BasePathFunction" # lambda function that supports custom resource
      {
        BasePathMapping: {
          Type: "Custom::BasePathMapping",
          Properties: {
            ServiceToken: "!GetAtt #{function_logical_id}.Arn",
            # A change to any of these properties updates the CloudFormation Custom Resource
            # IE: It runs the Lambda function that implements the custom resource
            BasePath: Jets.config.domain.base_path, # '' empty path represents root
            DomainName: "!Ref DomainName",
            RestApiId: "!Ref RestApi",
            Stage: Jets::Cfn::Resource::ApiGateway::Deployment.stage_name,
          },
        }
      }
    end

    def outputs
      {
        BasePathMapping: "!Ref BasePathMapping",
      }
    end
  end
end