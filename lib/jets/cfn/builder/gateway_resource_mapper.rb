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

    def parent_id
      if @path.include?('/')
        parent_path = @path.split('/')[0..-2].join('/')
        parent_logical_id = path_logical_id(parent_path)
        "!Ref ApiGatewayResource#{parent_logical_id}"
      else
        "!GetAtt ApiGatewayRestApi.RootResourceId"
      end
    end

    def path_part
      last_part = path.split('/').last
    end

  private
    def common_logical_id
      path_logical_id(@path)
    end

    def path_logical_id(path)
      path.gsub('/','_').gsub(':','').camelize
    end
  end
end