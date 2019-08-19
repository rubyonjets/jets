module Jets::Cfn::Builders
  class ApiGatewayBuilder
    include Interface
    include Paged
    include Jets::AwsServices

    def initialize(options={})
      @options = options
      push(ActiveSupport::HashWithIndifferentAccess.new(Resources: {}))
    end

    # template is an interface method
    def template 
      current_page
    end

    # compose is an interface method
    def compose
      return unless @options[:templates] || @options[:stack_type] != :minimal

      populate_base_template
      add_gateway_routes
    end

    # template_path is an interface method
    def template_path
      case current_page_number
      when 0
        return Jets::Naming.api_gateway_template_path('')
      else
        return Jets::Naming.api_gateway_template_path("-#{current_page_number}")
      end
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
      domain_name = Jets::Resource::ApiGateway::DomainName.new
      add_resource(domain_name)
      add_outputs(domain_name.outputs)
    end

    def add_route53_dns
      dns = Jets::Resource::Route53::RecordSet.new
      add_resource(dns)
      add_outputs(dns.outputs)
    end

    # The base template holds RestApi, DomainName, and DnsRecord
    # The base template will be added to the parent template as "ApiGateway"
    # Giving the original name will limit the number of changes required for
    # the AWS 60 output limit change.
    def populate_base_template
      add_gateway_rest_api
      add_custom_domain
    end

    # Adds route related Resources and Outputs
    def add_gateway_routes
      # The routes required a Gateway Resource to contain them.
      # TODO: Support more routes. Right now outputing all routes in 1 template will hit the 60 routes limit.
      # Will have to either output them as a joined string or break this up to multiple templates.
      # http://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/cloudformation-limits.html
      # Outputs: Maximum number of outputs that you can declare in your AWS CloudFormation template. 60 outputs
      # Output name: Maximum size of an output name. 255 characters.
      #
      # Note we must use .all_paths, not .routes here because we need to
      # build the parent ApiGateway::Resource nodes also
      new_template
      add_gateway_routes_parameters
      Jets::Router.all_paths.each do |path|
        homepage = path == ''
        next if homepage # handled by RootResourceId output already

        resource = Jets::Resource::ApiGateway::Resource.new(path, internal: true)
        add_resource(resource)
        add_outputs_across_templates(resource.outputs)
      end
    end

    def add_gateway_routes_parameters
      add_parameters({
        "RestApi" => "RestApi"
      })
    end

    def add_outputs_across_templates(attributes)
      attributes.each do |name,value|
        add_output(name.to_s.camelize, Value: value)
        new_template if template[:Outputs].length >= 60
      end
    end

    def new_template
      push(ActiveSupport::HashWithIndifferentAccess.new(Resources: {}))
    end
  end
end
