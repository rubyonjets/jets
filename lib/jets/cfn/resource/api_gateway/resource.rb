module Jets::Cfn::Resource::ApiGateway
  class Resource < Jets::Cfn::Base
    def initialize(path, internal: false)
      # The original implementation uses path without the leading slash.
      # Remove it here so the path_part is calculated correctly.
      @path = path.delete_prefix('/') # Examples: "posts/:id/edit" or "posts"
      @internal = internal
    end

    def definition
      {
        resource_logical_id => {
          Type: "AWS::ApiGateway::Resource",
          Properties: {
            ParentId: parent_id,
            PathPart: path_part,
            RestApiId: "!Ref #{RestApi.logical_id(@internal)}",
          }
        }
      }
    end

    def outputs
      {
        logical_id => "!Ref #{logical_id}",
      }
    end

    def resource_logical_id
      if @path == ''
        # Not including ApiResource in the logical id so it doesn't collide with a
        # user-defined ApiResource that happens to be named RootResourceId.
        "RootResourceId"
      else
        Jets::Cfn::Resource.truncate_id(path_logical_id(@path), "ApiResource")
      end
    end

    # For parameter description
    def desc
      path.empty? ? 'Homepage route: /' : "Route for: /#{path}"
    end

    def parent_path_parameter
      if @path.include?('/') # posts/:id or posts/:id/edit
        parent_path = @path.split('/')[0..-2].join('/')
        parent_logical_id = path_logical_id(parent_path)
        Jets::Cfn::Resource.truncate_id(parent_logical_id, "ApiResource")
      else
        "RootResourceId"
      end
    end

    def parent_id
      "!Ref " + parent_path_parameter
    end

    def path_part
      last_part = path.split('/').last
      last_part.split('/').map {|s| transform_capture(s) }.join('/') if last_part
    end

    # Modify the path to conform to API Gateway capture expressions
    def path
      @path.split('/').map {|s| transform_capture(s) }.join('/')
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

  private
    # Similar path_logical_id method in resource/route.rb
    def path_logical_id(path)
      path.gsub('/','_').gsub(':','').gsub('*','').gsub('-','_').gsub('.','_').camelize
    end
  end
end
