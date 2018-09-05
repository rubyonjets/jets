module Jets::Resource::ChildStack
  class ApiDeployment < Jets::Resource::Base
    def initialize(s3_bucket)
      @s3_bucket = s3_bucket
    end

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
      {
        RestApi: "!GetAtt ApiGateway.Outputs.RestApi",
      }
    end

    def depends_on
      expression = "#{Jets::Naming.template_path_prefix}-*_controller*"
      controller_logical_ids = []
      Dir.glob(expression).each do |path|
        next unless File.file?(path)

        # map the path to a camelized logical_id. Example:
        #   /tmp/jets/demo/templates/demo-dev-2-posts_controller.yml to
        #   PostsController
        regexp = Regexp.new(".*#{Jets.config.project_namespace}-")
        controller_name = path.sub(regexp, '').sub('.yml', '')
        controller_logical_id = controller_name.underscore.camelize
        controller_logical_ids << controller_logical_id
      end
      controller_logical_ids
    end

    def outputs
      {
        logical_id => "!Ref #{logical_id}",
      }
    end

    def deployment_id
      Jets::Resource::ApiGateway::Deployment.logical_id
    end

    def template_url
      path = File.basename("#{Jets.config.project_namespace}-api-deployment.yml")
      "https://s3.amazonaws.com/#{@s3_bucket}/jets/cfn-templates/#{path}"
    end
  end
end
