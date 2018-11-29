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
      klass = current_app_class.constantize
      return unless klass.depends_on

      klass.depends_on.map do |shared_stack|
        shared_stack.to_s.camelize # logical_id
      end
    end

    def depends_on_params
      params = {}
      depends_on.each do |dependency|
        dependency_outputs(dependency).each do |output|
          dependency_class = dependency.to_s.classify
          params[output] = "!GetAtt #{dependency_class}.Outputs.#{output}"
        end
      end
      params
    end

    def dependency_outputs(dependency)
      dependency.to_s.classify.constantize.output_keys
    end

    def parameters
      common = self.class.common_parameters
      common.merge!(controller_params) if controller?
      common.merge!(depends_on_params) if depends_on
      common
    end

    def self.common_parameters
      parameters = {
        IamRole: "!GetAtt IamRole.Arn",
        S3Bucket: "!Ref S3Bucket",
      }
      parameters[:GemLayer] = "!Ref GemLayer" unless Jets.poly_only?
      parameters
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
      templates_prefix = "#{Jets::Naming.template_path_prefix}-app-"
      @path.sub(templates_prefix, '')
        .sub(/\.yml$/,'')
        .gsub('-','/')
        .classify
    end

    # map the path to a camelized logical_id. Example:
    #   /tmp/jets/demo/templates/demo-dev-2-posts_controller.yml to
    #   PostsController
    def app_logical_id
      regexp = Regexp.new(".*#{Jets.config.project_namespace}-app-")
      controller_name = @path.sub(regexp, '').sub('.yml', '')
      controller_name.underscore.camelize
    end

    def template_filename
      @path
    end
  end
end