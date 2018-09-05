module Jets::Resource::ChildStack
  class AppClass < Jets::Resource::Base
    def initialize(path, s3_bucket)
      @path = path
      @s3_bucket = s3_bucket
    end

    def definition
      logical_id = app_logical_id
      {
        logical_id => {
          type: "AWS::CloudFormation::Stack",
          properties: {
            template_url: template_url,
            parameters: parameters,
          }
        }
      }
    end

    def parameters
      common = {
        IamRole: "!GetAtt IamRole.Arn",
        S3Bucket: "!Ref S3Bucket",
      }
      common.merge!(controller_params) if controller?
      common
    end

    def controller_params
      return {} if Jets::Router.routes.empty?

      params = {
        RestApi: "!GetAtt ApiGateway.Outputs.RestApi",
      }
      scoped_routes.each do |route|
        resource = Jets::Resource::ApiGateway::Resource.new(route.path)
        params[resource.logical_id] = "!GetAtt ApiGateway.Outputs.#{resource.logical_id}"
      end
      params
    end

    def controller?
      @path.include?('_controller.yml')
    end

    def scoped_routes
      @routes ||= Jets::Router.routes.select do |route|
        route.controller_name == current_app_class
      end
    end

    def current_app_class
      templates_prefix = "#{Jets::Naming.template_path_prefix}-"
      @path.sub(templates_prefix, '')
        .sub(/\.yml$/,'')
        .gsub('-','/')
        .classify
    end

    def outputs
      {
        logical_id => "!Ref #{logical_id}",
      }
    end

    # Dont name logical id because that is in Jets::Resource
    # map the path to a camelized logical_id. Example:
    #   /tmp/jets/demo/templates/demo-dev-2-posts_controller.yml to
    #   PostsController
    def app_logical_id
      regexp = Regexp.new(".*#{Jets.config.project_namespace}-")
      controller_name = @path.sub(regexp, '').sub('.yml', '')
      controller_name.underscore.camelize
    end

    def template_url
      "https://s3.amazonaws.com/#{@s3_bucket}/jets/cfn-templates/#{File.basename(@path)}"
    end
  end
end