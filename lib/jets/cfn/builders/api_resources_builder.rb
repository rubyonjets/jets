module Jets::Cfn::Builders
  class ApiResourcesBuilder
    include Interface
    include Jets::AwsServices

    def initialize(options={}, paths=[], page)
      @options, @paths, @page = options, paths, page
      @template = ActiveSupport::HashWithIndifferentAccess.new(Resources: {})
    end

    # compose is an interface method
    def compose
      add_rest_api_parameter
      add_gateway_routes
    end

    # template_path is an interface method
    def template_path
      Jets::Naming.api_resources_template_path(@page)
    end

    def add_rest_api_parameter
      add_parameter("RestApi", Description: "RestApi")
    end

    def add_gateway_routes
      @paths.each do |path|
        homepage = path == ''
        next if homepage # handled by RootResourceId output already

        resource = Jets::Resource::ApiGateway::Resource.new(path)
        add_resource(resource)
        add_outputs(resource.outputs)

        parent_path = resource.parent_path_parameter
        add_parameter(parent_path) unless part_of_template?(parent_path)
      end
    end

    def part_of_template?(parent_path)
      @template["Resources"].key?(parent_path)
    end
  end
end
