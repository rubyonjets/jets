module Jets::Cfn::Builders
  class ApiGatewayBuilder
    extend Memoist  
    include Interface
    include Paged
    include Jets::AwsServices

    AWS_OUTPUT_LIMIT = 20

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
      Jets::Naming.api_gateway_template_path("-#{current_page_number}")
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
      indexed_paths.each do |path, page_number|
        homepage = path == ''
        next if homepage # handled by RootResourceId output already
        turn_to_page(page_number)
        resource = Jets::Resource::ApiGateway::Resource.new(path, internal: true, indexed_paths: indexed_paths)
        add_resource(resource)
        add_outputs_and_exports(resource.outputs)
        add_gateway_routes_parameters
      end
    end

    def add_gateway_routes_parameters
      add_parameter('RestApi', Description: 'RestApi') 
      add_parameter('RootResourceId', Description: 'RootResourceId')  
    end

    def add_outputs_and_exports(attributes) 
      attributes.each do |name,value|
        camelized_name = name.to_s.camelize
        add_output(camelized_name, value)
      end
    end
    
    # Gateway routes are split across multiple CloudFormation templates because of a 60 Output limit by AWS.
    # Having a resource and its corresponding parent resource ( :ParentId ) in the same template is not guaranteed
    # so routes are indexed up front to allow us to determine how to find :ParentId ( !Ref vs !ImportValue )
    def indexed_paths
      # indexed_paths is a Hash with key => path and value => page_number.  Each page number represents a separate 
      # template for the routes contained in it.
      # The reason for making the hash is we need to pass these indexed_paths to Jets::Resource::ApiGateway::Resource so it can
      # easily determine what page a parent path is in.
      # NOTE: that we are trying to keep Outputs to 60 and below, however, we are indexing "paths" here.  Currently there 
      # is a one to one relationship to paths and outputs for Jets::Resource::ApiGateway::Resource.  If that one to one changes
      # this solution will not work
      indexed_paths = Hash.new
      # root path == RootResource which comes off RestApi and is in ApiGateway0
      indexed_paths[''] = 0
      starting_index = 0
      page = 1
      loop do
        new_template # create new template here since we know we will need this page later
        Jets::Router.all_paths[starting_index, AWS_OUTPUT_LIMIT].each do |path|
          next if path.empty?
          indexed_paths[path] = page
        end
        starting_index += AWS_OUTPUT_LIMIT
        page += 1
        break if starting_index >= Jets::Router.all_paths.length
      end

      indexed_paths
    end
    memoize :indexed_paths

    def new_template
      push(ActiveSupport::HashWithIndifferentAccess.new(Resources: {}))
    end
  end
end
