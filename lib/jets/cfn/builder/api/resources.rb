module Jets::Cfn::Builder::Api
  class Resources < Paged
    # interface method
    def compose
      add_gateway_resources
      add_rest_api_parameter
    end

    # interface method
    def template_path
      Jets::Names.api_resources_template_path(@page_number)
    end

    def add_rest_api_parameter
      add_parameter(:RestApi)
    end

    def add_gateway_resources
      @items.each do |path|
        # IE: resource = Jets::Cfn::Resource::ApiGateway::Resource.new(path)
        next if path == '/' || path == '' # skip root path
        resource = api_gateway_resource_class.new(path)
        add_resource(resource)
        add_outputs(resource.outputs)

        parent_path = resource.parent_path_parameter
        add_parameter(parent_path) unless part_of_template?(parent_path)
      end
    end

    # interface method
    def api_gateway_resource_class
      Jets::Cfn::Resource::ApiGateway::Resource
    end

    def part_of_template?(parent_path)
      @template[:Resources].key?(parent_path)
    end
  end
end
