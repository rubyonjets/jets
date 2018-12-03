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
module Jets::Resource::ApiGateway::BasePath
  class Mapping < Jets::Resource::Base
    def definition
      function_logical_id = "BasePathFunction" # lambda function that supports custom resource
      {
        base_path_mapping: {
          type: "Custom::BasePathMapping",
          properties: {
            service_token: "!GetAtt #{function_logical_id}.Arn",
            # base_path: '', # empty path represents root
            # domain_name: "!Ref DomainName",
            # rest_api_id: "!Ref RestApi", # since this is in the Deployment template
            # stage: Deployment.stage_name,
          },
          depends_on: Jets::Resource::ApiGateway::Deployment.logical_id,
        }
      }
    end

    def outputs
      {
        "BasePathMapping" => "!Ref BasePathMapping",
      }
    end
  end
end