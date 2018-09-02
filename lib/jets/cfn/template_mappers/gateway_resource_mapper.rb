class Jets::Cfn::TemplateMappers
  class GatewayResourceMapper
    def initialize(path)
      @path = path # Examples: "posts/:id/edit" or "posts"
    end

    # Returns: "ApiResourcePostsController"
    def logical_id
      homepage = @path == ''
      if homepage
        "RootApiResource"
      else
        "#{path_logical_id(@path)}ApiResource"
      end
    end

    def cors_logical_id
      "#{path_logical_id(@path)}CorsApiResource"
    end

    # Modify the path to conform to API Gateway capture expressions
    def path
      @path.split('/').map {|s| transform_capture(s) }.join('/')
    end

    def desc
      path.empty? ? 'Homepage route: /' : "Route for: /#{path}"
    end

    def transform_capture(text)
      if text.starts_with?(':')
        text = text.sub(':','')
        text = "{#{text}}" # :foo => {foo}
      end
      if text.starts_with?('*')
        text = text.sub('*','')
        text = "{#{text}+}" # *foo => {foo+}
      end
      text
    end

    def parent_id
      if @path.include?('/') # posts/:id or posts/:id/edit
        parent_path = @path.split('/')[0..-2].join('/')
        parent_logical_id = path_logical_id(parent_path)
        "!Ref #{parent_logical_id}ApiResource"
      else
        "!GetAtt RestApi.RootResourceId"
      end
    end

    def path_part
      last_part = path.split('/').last
      last_part.split('/').map {|s| transform_capture(s) }.join('/')
    end

  private
    # Similar path_logical_id method in resource/route.rb
    def path_logical_id(path)
      path.gsub('/','_').gsub(':','').gsub('*','').camelize
    end
  end
end
