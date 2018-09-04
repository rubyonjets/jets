module Jets::Resource::ChildStack
  class ApiGatewayDeployment < Jets::Resource::Base
    def initialize(s3_bucket)
      @s3_bucket = s3_bucket
    end

    def definition
      {
        Jets::Resource::ApiGateway::Deployment.logical_id => {
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
      {
        IamRole: "!GetAtt IamRole.Arn",
        S3Bucket: "!Ref S3Bucket",
      }
    end

# path = "#{Jets.config.project_namespace}-api-gateway-deployment.yml"
# map = Jets::Cfn::TemplateMappers::ApiGatewayDeploymentMapper.new(path, @options[:s3_bucket])
# add_resource(map.logical_id, "AWS::CloudFormation::Stack",
#   Properties: {
#     TemplateURL: map.template_url,
#     Parameters: map.parameters
#   },
#   DependsOn: map.depends_on
# )

    def depends_on
      expression = "#{Jets::Naming.template_path_prefix}-*_controller*"
      controller_logical_ids = []
      Dir.glob(expression).each do |path|
        next unless File.file?(path)

        # map the path to a camelized logical_id. Example:
        #   /tmp/jets/demo/templates/demo-dev-2-posts_controller.yml to
        #   PostsController
        regexp = Regexp.new(".*#{Jets.config.project_namespace}-")
        contoller_name = path.sub(regexp, '').sub('.yml', '')
        controller_logical_id = contoller_name.underscore.camelize
        controller_logical_ids << controller_logical_id
      end
      controller_logical_ids
    end

    def outputs
      {
        logical_id => "!Ref #{logical_id}",
      }
    end

    def template_url
      path = "#{Jets.config.project_namespace}-api-gateway-deployment.yml"
      "https://s3.amazonaws.com/#{@s3_bucket}/jets/cfn-templates/#{path}"
    end
  end
end
