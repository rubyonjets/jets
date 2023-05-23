module Jets::Cfn::Resource::Nested::Api
  class Deployment < Base
    # interface method
    def definition
      {
        deployment_id => {
          Type: "AWS::CloudFormation::Stack",
          Properties: {
            TemplateURL: template_url,
            Parameters: parameters,
          },
          DependsOn: depends_on,
        }
      }
    end

    def parameters
      { RestApi: "!GetAtt ApiGateway.Outputs.RestApi" }
    end

    def depends_on
      depends_on_controllers + depends_on_api_methods
    end

    def depends_on_api_methods
      pages = Jets::Cfn::Builder::Api::Pages::Methods.pages
      pages.map do |page|
        "ApiMethods#{page.number}"
      end
    end

    def depends_on_controllers
      controller_logical_ids = []
      expression = "#{Jets::Names.templates_folder}/*_controller*"
      Dir.glob(expression).each do |path|
        next unless File.file?(path)

        # map the path to a camelized logical_id. Example:
        #   /tmp/jets/demo/templates/demo-dev-2-posts_controller.yml to
        #   PostsController
        regexp = Regexp.new(".*#{Jets::Names.templates_folder}/app-")
        controller_name = path.sub(regexp, '').sub('.yml', '')
        controller_logical_id = controller_name.underscore.camelize
        controller_logical_ids << controller_logical_id
      end
      controller_logical_ids
    end

    def deployment_id
      Jets::Cfn::Resource::ApiGateway::Deployment.logical_id
    end
  end
end
