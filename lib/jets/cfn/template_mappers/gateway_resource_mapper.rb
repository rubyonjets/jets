class Jets::Cfn::TemplateMappers
  class GatewayResourceMapper
    def initialize(path)
      @path = path # Examples: "posts/:id/edit" or "posts"
    end

    # Returns: "ApiGatewayResourcePostsController"
    def logical_id
      "#{path_logical_id(@path)}ApiGatewayResource"
    end

    def cors_logical_id
      "#{path_logical_id(@path)}CorsApiGatewayResource"
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
        "!Ref #{parent_logical_id}ApiGatewayResource"
      else
        "!GetAtt RestApi.RootResourceId"
      end
    end

    def path_part
      last_part = path.split('/').last
    end

  private
    def path_logical_id(path)
      path.gsub('/','_').gsub(':','').gsub('*','').camelize
    end
  end
end
