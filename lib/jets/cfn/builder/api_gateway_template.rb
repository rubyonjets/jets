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
      add_api_gateway_resources
    end

    # template_path is an interface method
    def template_path
      Jets::Naming.api_gateway_template_path
    end

    def add_api_gateway_resources
      # The routes required a Gateway Resource to contain them.
      paths = all_routes.map(&:path)
      all_paths(paths).each do |path|
        puts "path #{path}".colorize(:red)
        map = GatewayResourceMapper.new(path)
        add_resource(map.gateway_resource_logical_id, "AWS::ApiGateway::Resource",
          ParentId: map.parent_id,
          PathPart: map.path_part,
          RestApiId: "!Ref ApiGatewayRestApi"
        )
      end
    end

    # Returns all paths including subpaths.
    # Example:
    # Input: ["posts/:id/edit"]
    # Output: ["posts", "posts/:id", "posts/:id/edit"]
    def all_paths(paths)
      results = []
      paths.each do |p|
        sub_paths = []
        parts = p.split('/')
        until parts.empty?
          parts.pop
          sub_path = parts.join('/')
          sub_paths << sub_path unless sub_path == ''
        end
        results += sub_paths
      end
      (results + paths).sort.uniq
    end

    def all_routes
      @all_routes ||= Jets::Build::RoutesBuilder.routes
    end
  end
end
