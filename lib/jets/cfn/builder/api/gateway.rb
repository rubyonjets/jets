module Jets::Cfn::Builder::Api
  class Gateway < Base
    # interface method
    def compose
      add_gateway_rest_api # changes parent template
      add_custom_domain    # changes parent template
      add_client_certificate   # changes parent template
    end

    # interface method
    def template_path
      Jets::Names.api_gateway_template_path
    end

    # do write a template if routes are empty
    def write
      super unless Jets::Router.no_routes?
    end

    # If the are routes in config/routes.rb add Gateway API in parent stack
    def add_gateway_rest_api
      rest_api = Jets::Cfn::Resource::ApiGateway::RestApi.new
      add_resource(rest_api)
      add_outputs(rest_api.outputs)

      deployment = Jets::Cfn::Resource::ApiGateway::Deployment.new
      outputs = deployment.outputs(true)
      add_output(:RestApiUrl, Value: outputs[:RestApiUrl])
    end

    def add_custom_domain
      return unless Jets.custom_domain?
      add_domain_name
      add_route53_dns if Jets.config.domain.route53
    end

    def add_domain_name
      add_outputs(create_domain_name)
    end

    def add_route53_dns
      dns = Jets::Cfn::Resource::Route53::RecordSet.new
      if !existing_domain_name?(dns.domain_name) or existing_dns_record_on_stack?
        add_resource(dns)
        add_outputs(dns.outputs)
      end
    end

    def add_client_certificate
      p Jets.config.class
      return unless Jets.config.stage.client_certificate

      unless Jets.config.stage.client_certificate.kind_of?(String)
        add_outputs(create_client_certificate)
        Jets.config.stage.client_certificate = "!Ref ClientCertificate"
      end

      stage = Jets::Cfn::Resource::ApiGateway::Stage.new
      add_resource(stage)
      add_outputs(stage.outputs)
    end

    def create_domain_name
      resource = Jets::Cfn::Resource::ApiGateway::DomainName.new

      return {
        DomainName: resource.domain_name
      } if (existing_domain_name?(resource) and !existing_domain_name_on_stack?)

      add_resource(resource)
      return resource.outputs
    end

    def create_client_certificate
      resource = Jets::Cfn::Resource::ApiGateway::ClientCertificate.new

      add_resource(resource)
      return resource.outputs
    end

    def existing_domain_name?(resource)
      apigateway.get_domain_name(
        domain_name: resource.domain_name
      )
      true
    # IE: Aws::APIGateway::Errors::NotFoundException Invalid domain name identifier specified
    rescue Aws::APIGateway::Errors::NotFoundException
      false
    end
    memoize :existing_domain_name?

    def existing_domain_name_on_stack?
      cfn.describe_stack_resource(
        stack_name: api_gateway_physical_resource_id,
        logical_resource_id: "DomainName"
      )
      true
    # IE: Aws::CloudFormation::Errors::ValidationError (Resource DomainName does not exist for stack demo-dev)
    rescue Aws::CloudFormation::Errors::ValidationError
      false
    end

    def existing_dns_record_on_stack?
      cfn.describe_stack_resource(
        stack_name: api_gateway_physical_resource_id,
        logical_resource_id: "DnsRecord"
      )
      true
    # IE: Aws::CloudFormation::Errors::ValidationError (Resource DnsRecord does not exist for stack demo-dev)
    rescue Aws::CloudFormation::Errors::ValidationError
      false
    end

    def api_gateway_physical_resource_id
      resp = cfn.describe_stack_resource(
        stack_name: Jets::Names.parent_stack_name,
        logical_resource_id: "ApiGateway"
      )
      resp&.stack_resource_detail&.physical_resource_id
    # IE: Aws::CloudFormation::Errors::ValidationError (Resource ApiGateway does not exist for stack demo-dev)
    rescue Aws::CloudFormation::Errors::ValidationError
      nil
    end
    memoize :api_gateway_physical_resource_id
  end
end
