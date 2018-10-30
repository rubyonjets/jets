# This class groups the naming in one place.
# Some naming is for CloudFormation
# Some are for the Build process
class Jets::Naming
  # Mainly used by build.rb
  class << self
    extend Memoist

    def app_template_path(app_class)
      underscored = app_class.to_s.underscore.gsub('/','-')
      "#{template_path_prefix}-app-#{underscored}.yml"
    end

    def shared_template_path(shared_class)
      underscored = shared_class.to_s.underscore.gsub('/','-')
      "#{template_path_prefix}-shared-#{underscored}.yml"
    end

    def template_path_prefix
      "#{Jets.build_root}/templates/#{Jets.config.project_namespace}"
    end

    # consider moving these methods into cfn/builder/helpers.rb or that area.
    def parent_template_path
      "#{template_path_prefix}.yml"
    end

    # consider moving these methods into cfn/builder/helpers.rb or that area.
    def api_gateway_template_path
      "#{template_path_prefix}-api-gateway.yml"
    end

    def api_deployment_template_path
      "#{template_path_prefix}-api-deployment.yml"
    end

    def shared_resources_template_path
      "#{template_path_prefix}-shared-resources.yml"
    end

    def parent_stack_name
      File.basename(parent_template_path, ".yml")
    end

    def gateway_api_name
      "#{Jets.config.project_namespace}"
    end
  end
end
