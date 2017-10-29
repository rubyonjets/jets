class Jets::Cfn::Builder
  class GatewayResourceMapper
    def initialize(path)
      @path = path # Examples: "posts/:id/edit" or "posts"
    end

    # Modify the path to confirm to API Gateway capture expressions
    def path
      @path.split('/').map {|s| transform_capture(s) }.join('/')
    end

    def transform_capture(text)
      if text.starts_with?(':')
        text = text.sub(':','')
        text = "{#{text}}"
      end
      text
    end

    # Returns: "ApiGatewayResourcePostsController"
    def gateway_resource_logical_id
      "ApiGatewayResource#{common_logical_id}"
    end

    def path_part
      last_part = path.split('/').last
    end

  private
    def common_logical_id
      @path.gsub('/','_').gsub(':','').camelize
    end
  end
end