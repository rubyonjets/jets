module Jets::Cfn::Builders
  class ApiGatewayBuilder
    extend Memoist
    include Interface
    include Jets::AwsServices

    def initialize(options={})
      @options = options
      @template = ActiveSupport::HashWithIndifferentAccess.new(Resources: {})
    end

    # compose is an interface method
    def compose
      add_gateway_routes # "child template": build before add_gateway_rest_api. RestApi logical id and change detection is dependent on it.
      add_gateway_rest_api # changes parent template
      add_custom_domain    # changes parent template
    end

    # template_path is an interface method
    def template_path
      Jets::Naming.api_gateway_template_path
    end

    # do not bother writing a template if routes are empty
    def write
      super unless Jets::Router.routes.empty?
    end

    # If the are routes in config/routes.rb add Gateway API in parent stack
    def add_gateway_rest_api
      rest_api = Jets::Resource::ApiGateway::RestApi.new
      add_resource(rest_api)
      add_outputs(rest_api.outputs)

      deployment = Jets::Resource::ApiGateway::Deployment.new
      outputs = deployment.outputs(true)
      add_output("RestApiUrl", Value: outputs["RestApiUrl"])
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
      dns = Jets::Resource::Route53::RecordSet.new
      if !existing_domain_name?(dns.domain_name) or existing_dns_record_on_stack? 
        add_resource(dns)
        add_outputs(dns.outputs)
      end
    end

    def create_domain_name()
      resource = Jets::Resource::ApiGateway::DomainName.new
      
      return {
        "DomainName" => resource.domain_name
      } if (existing_domain_name?(resource) and !existing_domain_name_on_stack?)
      
      add_resource(resource)
      return resource.outputs
    end

    def existing_domain_name?(resource)
      apigateway.get_domain_name({
        domain_name: resource.domain_name
      })
      return true
    rescue
      return false
    end
    memoize :existing_domain_name?

    def existing_domain_name_on_stack?
      cfn.describe_stack_resource({
        stack_name: api_gateway_physical_resource_id,
        logical_resource_id: "DomainName"
      })
      return true
    rescue
      return false
    end

    def existing_dns_record_on_stack?
      cfn.describe_stack_resource({
        stack_name: api_gateway_physical_resource_id,
        logical_resource_id: "DnsRecord"
      })
      return true
    rescue
      return false
    end

    def api_gateway_physical_resource_id
      cfn.describe_stack_resource({
        stack_name: Jets::Naming.parent_stack_name,
        logical_resource_id: "ApiGateway"
      })
      .stack_resource_detail
      .physical_resource_id
    rescue
      return nil
    end
    memoize :api_gateway_physical_resource_id

    # Adds route related Resources and Outputs
    # Delegates to ApiResourcesBuilder
    PAGE_LIMIT = Integer(ENV['JETS_AWS_OUTPUTS_LIMIT'] || 200) # Allow override for testing
    def add_gateway_routes
      # Reject homepage. Otherwise we have 200 - 1 resources on the first page.
      # There's a next call in ApiResources.add_gateway_resources to skip the homepage.
      all_paths = Jets::Router.all_paths.reject { |p| p == '' }
      all_paths.each_slice(PAGE_LIMIT).each_with_index do |paths, i|
        ApiResourcesBuilder.new(@options, paths, i+1).build
      end
    end
  end
end
