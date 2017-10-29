class Jets::Cfn::Builder
  class ApiGatewayTemplate
    include Helpers
    include Jets::AwsServices

    def initialize(options={})
      @options = options
      @template = ActiveSupport::HashWithIndifferentAccess.new(Resources: {})
    end

    # compose is an interface method
    def compose
      return if @options[:stack_type] == 'minimal'

      puts "Building API Gateway Resources template"
      add_gateway_rest_api
      add_api_gateway_resources
    end

    # template_path is an interface method
    def template_path
      Jets::Naming.api_gateway_template_path
    end

    # If the are routes in config/routes.rb add Gateway API in parent stack
    def add_gateway_rest_api
      return unless Jets::Build::RoutesBuilder.routes.size > 0

      add_resource("ApiGatewayRestApi", "AWS::ApiGateway::RestApi",
        Name: Jets::Naming.gateway_api_name
      )
    end

    def add_api_gateway_resources
      # The routes required a Gateway Resource to contain them.
      add_output("ApiGatewayRestApi", Value: "!Ref ApiGatewayRestApi")
      Jets::Build::RoutesBuilder.all_paths.each do |path|
        puts "path #{path}".colorize(:red)
        map = GatewayResourceMapper.new(path)
        add_resource(map.gateway_resource_logical_id, "AWS::ApiGateway::Resource",
          ParentId: map.parent_id,
          PathPart: map.path_part,
          RestApiId: "!Ref ApiGatewayRestApi"
        )
        add_output(map.gateway_resource_logical_id,
          Value: "!Ref #{map.gateway_resource_logical_id}"
        )
      end
    end
  end
end
