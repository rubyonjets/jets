class Jets::Resource::ApiGateway::RestApi::Routes::Change
  class MediaTypes < Base
    def changed?
      current_binary_media_types != new_binary_media_types
    end

    def new_binary_media_types
      rest_api = Jets::Resource::ApiGateway::RestApi.new
      rest_api.binary_media_types
    end
    memoize :new_binary_media_types

    def current_binary_media_types
      return nil unless parent_stack_exists?

      stack = cfn.describe_stacks(stack_name: parent_stack_name).stacks.first

      api_gateway_stack_arn = lookup(stack[:outputs], "ApiGateway")

      stack = cfn.describe_stacks(stack_name: api_gateway_stack_arn).stacks.first
      rest_api_id = lookup(stack[:outputs], "RestApi")

      resp = apigateway.get_rest_api(rest_api_id: rest_api_id)
      resp.binary_media_types
    end
    memoize :current_binary_media_types

    def parent_stack_exists?
      stack_exists?(parent_stack_name)
    end

    def parent_stack_name
      Jets::Naming.parent_stack_name
    end
  end
end
