# Implements:
#
#   definition
#   template_filename
#
module Jets::Resource::ChildStack
  class AppClass < Base
    def initialize(s3_bucket, options={})
      super
      @path = options[:path]
    end

    def definition
      logical_id = app_logical_id
      defintion = {
        logical_id => {
          type: "AWS::CloudFormation::Stack",
          properties: {
            template_url: template_url,
            parameters: parameters,
          }
        }
      }
      defintion[logical_id][:depends_on] = depends_on if depends_on
      defintion
    end

    def depends_on
      return nil
      # return unless Jets::Stack.has_resources?

      # expression = "#{Jets::Naming.template_path_prefix}-shared-*"
      # shared_logical_ids = []
      # Dir.glob(expression).each do |path|
      #   next unless File.file?(path)

      #   # map the path to a camelized logical_id. Example:
      #   #   /tmp/jets/demo/templates/demo-dev-2-shared-resource.yml to
      #   #   SharedResource
      #   regexp = Regexp.new(".*#{Jets.config.project_namespace}-")
      #   shared_name = path.sub(regexp, '').sub('.yml', '')
      #   shared_logical_id = shared_name.underscore.camelize
      #   shared_logical_ids << shared_logical_id
      # end
      # shared_logical_ids
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

    # map the path to a camelized logical_id. Example:
    #   /tmp/jets/demo/templates/demo-dev-2-posts_controller.yml to
    #   PostsController
    def app_logical_id
      regexp = Regexp.new(".*#{Jets.config.project_namespace}-")
      controller_name = @path.sub(regexp, '').sub('.yml', '')
      controller_name.underscore.camelize
    end

    def template_filename
      @path
    end
  end
end