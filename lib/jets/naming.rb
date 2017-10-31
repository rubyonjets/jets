# This class groups the naming in one place.
# Some naming is for CloudFormation
# Some are for the Build process
class Jets::Naming
  # Mainly used by build.rb
  class << self
    def temp_code_zipfile
      "#{Jets.root}code-temp.zip"
    end

    def template_path(controller_class)
      underscored_controller = controller_class.to_s.underscore.dasherize
      "#{template_path_prefix}-#{underscored_controller}.yml"
    end

    # consider moving these methods into cfn/builder/helpers.rb or that area.
    def parent_template_path
      "#{template_path_prefix}-parent.yml"
    end

    # consider moving these methods into cfn/builder/helpers.rb or that area.
    def api_gateway_template_path
      "#{template_path_prefix}-api-gateway.yml"
    end

    def api_gateway_deployment_template_path
      "#{template_path_prefix}-api-gateway-deployment.yml"
    end

    def parent_stack_name
      File.basename(parent_template_path, ".yml")
    end

    def template_path_prefix
      "/tmp/jets_build/templates/#{Jets::Config.project_namespace}"
    end

    def gateway_api_name
      "#{Jets::Config.project_namespace}"
    end
  end
end
