module Jets::Cfn::Resource::ApiGateway
  class ResourceId
    def initialize(path)
      @path = path
    end

    # Used by Method and Cors
    def resource_id
      @path == '/' ?
        "RootResourceId" :
        resource_logical_id.camelize + "ApiResource"
    end

    # Example: Posts
    def resource_logical_id
      camelized_path.underscore
    end

    def camelized_path
      path = @path
      path = "homepage" if path == '/'
      path.gsub('/','_').gsub(':','').gsub('*','').gsub('.','').camelize
    end
  end
end
