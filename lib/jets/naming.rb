# This class groups the naming in one place.
# Some naming is for CloudFormation
# Some are for the Build process
class Jets::Naming
  # Mainly used by build.rb
  class << self
    extend Memoist

    def app_template_path(app_class)
      underscored = underscore(app_class)
      "#{template_path_prefix}-app-#{underscored}.yml"
    end

    def shared_template_path(shared_class)
      underscored = underscore(shared_class)
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

    def api_resources_template_path(page)
      "#{template_path_prefix}-api-resources-#{page}.yml"
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

    def authorizer_template_path(path)
      underscored = underscore(path)
      underscored.sub!(/^app-/, '')
      "#{template_path_prefix}-#{underscored}.yml"
    end

    def underscore(s)
      s.to_s.underscore.sub(/\.rb$/,'').gsub('/','-')
    end
  end
end
