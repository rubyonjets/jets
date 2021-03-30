# Implements:
#
#   definition
#   template_filename
#
module Jets::Resource::ChildStack
  class ApiDeployment < Base
    def definition
      {
        deployment_id => {
          type: "AWS::CloudFormation::Stack",
          properties: {
            template_url: template_url,
            parameters: parameters,
          },
          depends_on: depends_on,
        }
      }
    end

    def parameters
      p = {
        GemLayer: "!Ref GemLayer",
        IamRole: "!GetAtt IamRole.Arn",
        RestApi: "!GetAtt ApiGateway.Outputs.RestApi",
        S3Bucket: "!Ref S3Bucket",
      }
      p[:DomainName] = "!GetAtt ApiGateway.Outputs.DomainName" if Jets.custom_domain?
      p[:BasePath] = Jets.config.domain.base_path unless Jets.config.domain.base_path.nil?
      p
    end

    def depends_on
      expression = "#{Jets::Naming.template_path_prefix}-*_controller*"
      controller_logical_ids = []
      Dir.glob(expression).each do |path|
        next unless File.file?(path)

        # map the path to a camelized logical_id. Example:
        #   /tmp/jets/demo/templates/demo-dev-2-posts_controller.yml to
        #   PostsController
        regexp = Regexp.new(".*#{Jets.config.project_namespace}-app-")
        controller_name = path.sub(regexp, '').sub('.yml', '')
        controller_logical_id = controller_name.underscore.camelize
        controller_logical_ids << controller_logical_id
      end
      controller_logical_ids
    end

    def deployment_id
      Jets::Resource::ApiGateway::Deployment.logical_id
    end

    def template_filename
      "#{Jets.config.project_namespace}-api-deployment.yml"
    end
  end
end
