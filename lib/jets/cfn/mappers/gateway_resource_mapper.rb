class Jets::Cfn::Mappers
  class GatewayResourceMapper
    def initialize(path)
      @path = path # Examples: "posts/:id/edit" or "posts"
    end

    # Returns: "ApiGatewayResourcePostsController"
    def logical_id
      "ApiGatewayResource#{path_logical_id(@path)}"
    end

    def cors_logical_id
      "#{logical_id}Cors"
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

    def parent_id
      if @path.include?('/') # posts/:id or posts/:id/edit
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
    def path_logical_id(path)
      path.gsub('/','_').gsub(':','').camelize
    end
  end
end
