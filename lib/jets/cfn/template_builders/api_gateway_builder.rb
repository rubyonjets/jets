class Jets::Cfn::TemplateBuilders
  class ApiGatewayBuilder
    include Interface
    include Jets::AwsServices

    def initialize(options={})
      @options = options
      @template = ActiveSupport::HashWithIndifferentAccess.new(Resources: {})
    end

    # compose is an interface method
    def compose
      return if @options[:stack_type] == 'minimal'

      puts "Building API Gateway template."
      add_gateway_rest_api
      add_gateway_routes
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
      add_resource("RestApi", "AWS::ApiGateway::RestApi",
        Name: Jets::Naming.gateway_api_name
      )
      add_output("RestApi", Value: "!Ref RestApi")
      add_output("RootResourceId", Value: "!GetAtt RestApi.RootResourceId")
    end

    # Adds route related Resources and Outputs
    def add_gateway_routes
      # The routes required a Gateway Resource to contain them.
      # TODO: outputing all routes in 1 template will hit the 60 routes limit
      # Will have to either output them as a joined string or
      # break this up to multiple tempaltes.
      # http://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/cloudformation-limits.html
      # Outputs: Maximum number of outputs that you can declare in your AWS CloudFormation template. 60 outputs
      # Output name: Maximum size of an output name. 255 characters.
      Jets::Router.routes.each do |route|
        map = Jets::Cfn::TemplateMappers::GatewayResourceMapper.new(route)

        unless route.root? # no AWS::ApiGateway::Resource for the top level route
          add_resource(map.logical_id, "AWS::ApiGateway::Resource",
            ParentId: map.parent_id,
            PathPart: map.path_part,
            RestApiId: "!Ref RestApi"
          )
        end

        add_output(map.logical_id, Value: "!Ref #{map.logical_id}")
      end
    end
  end
end
