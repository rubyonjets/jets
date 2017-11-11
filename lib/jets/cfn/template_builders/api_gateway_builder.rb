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

    # If the are routes in config/routes.rb add Gateway API in parent stack
    def add_gateway_rest_api
      add_resource("RestApi", "AWS::ApiGateway::RestApi",
        Name: Jets::Naming.gateway_api_name
      )
      add_output("RestApi", Value: "!Ref RestApi")
    end

    # Adds route related Resources and Outputs
    def add_gateway_routes
      # The routes required a Gateway Resource to contain them.
      Jets::Router.all_paths.each do |path|
        map = Jets::Cfn::TemplateMappers::GatewayResourceMapper.new(path)
        add_resource(map.logical_id, "AWS::ApiGateway::Resource",
          ParentId: map.parent_id,
          PathPart: map.path_part,
          RestApiId: "!Ref RestApi"
        )
        add_output(map.logical_id,
          Value: "!Ref #{map.logical_id}"
        )
      end
    end
  end
end
