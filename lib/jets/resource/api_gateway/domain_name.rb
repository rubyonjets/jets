# CloudFormation Docs AWS::ApiGateway::DomainName: https://amzn.to/2Bsnmbq
#
# Example:
#
#   MyDomainName:
#     Type: 'AWS::ApiGateway::DomainName'
#     Properties:
#       DomainName: api.mydomain.com
#       CertificateArn: arn:aws:acm:us-east-1:111122223333:certificate/fb1b9770-a305-495d-aefb-27e5e101ff3
#
module Jets::Resource::ApiGateway
  class DomainName < Jets::Resource::Base
    def definition
      properties = {
        domain_name: domain_name,
        endpoint_configuration: {
          types: endpoint_types
        }
      }
      # Can really only be REGIONAL or EDGE
      if endpoint_types.include?("REGIONAL")
        properties[:regional_certificate_arn] = cert_arn
      end
      if endpoint_types.include?("EDGE")
        properties[:certificate_arn] = cert_arn
      end

      {
        domain_name: {
          type: "AWS::ApiGateway::DomainName",
          properties: properties
        }
      }
    end

    def outputs
      {
        "DomainName" => "!Ref DomainName",
      }
    end

    def domain_name
      subdomain = Jets.project_namespace
      managed_domain_name = "#{subdomain}.#{Jets.config.domain.hosted_zone_name}"
      Jets.config.domain.name || managed_domain_name
    end

    def endpoint_types
      [Jets.config.domain.endpoint_type].flatten
    end

    def cert_arn
      Jets.config.domain.cert_arn
    end
  end
end
