module Jets::Resource::ApiGateway
  class Resource < Jets::Resource::Base
    def initialize(path, internal: false, indexed_paths: nil)
      @path = path # Examples: "posts/:id/edit" or "posts"
      @internal = internal
      @indexed_paths = indexed_paths unless indexed_paths.nil? 
    end

    def definition
      {
        resource_logical_id => {
          type: "AWS::ApiGateway::Resource",
          properties: {
            parent_id: parent_id,
            path_part: path_part,
            rest_api_id: "!Ref #{RestApi.logical_id(@internal)}",
          }
        }
      }
    end  

    def outputs
      {
        logical_id => {
          Value: "!Ref #{logical_id}", 
          # RDB no longer exporting
          # Export: {
          #   Name: "#{logical_id}-#{Jets::Resource::ApiGateway::Deployment.stage_name}"
          # }
        }
      }
    end

    def resource_logical_id
      if @path == ''
        "RootResourceId"
      else
        Jets::Resource.truncate_id "#{path_logical_id(@path)}ApiResource"
      end
    end

    # For parameter description
    def desc
      path.empty? ? 'Homepage route: /' : "Route for: /#{path}"
    end

    def parent_id
      if @path.include?('/') # posts/:id or posts/:id/edit
        parent_path = @path.split('/')[0..-2].join('/')
        parent_logical_id = path_logical_id(parent_path)

        resource_to_reference = Jets::Resource.truncate_id("#{parent_logical_id}ApiResource")
        if @indexed_paths
          # If the parent resource is not found in the same template as self, we need to save the parent
          # off se we can pass it in as a Parameter from the parent template
          path_page = @indexed_paths.fetch(@path)
          parent_path_page = @indexed_paths.fetch(parent_path)
          required_resources_from_parameters.push({
            :logical_id => resource_to_reference,
            :location => "ApiGateway#{parent_path_page}.Outputs.#{resource_to_reference}" 
          }) if path_page != parent_path_page 
        end
        "!Ref #{resource_to_reference}"
      else
        '!Ref RootResourceId'
      end
    end

    def required_resources_from_parameters
      @required_resources_from_parameters ||= []
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
      path.gsub('/','_').gsub(':','').gsub('*','').gsub('-','_').camelize
    end
  end
end
