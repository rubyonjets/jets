# This class groups the names in one place.
# Some names are for CloudFormation
# Some are for the Build process
class Jets::Names
  # Mainly used by build.rb
  class << self
    extend Memoist

    def templates_folder
      "#{Jets.build_root}/templates"
    end

    def one_controller_template_path
      "#{templates_folder}/controller.yml"
    end

    def ecs_template_path
      "#{templates_folder}/ecs.yml"
    end

    def app_template_path(app_class)
      underscored = underscore(app_class)
      "#{templates_folder}/app-#{underscored}.yml"
    end

    def shared_template_path(shared_class)
      underscored = underscore(shared_class)
      "#{templates_folder}/shared-#{underscored}.yml"
    end

    # consider moving these methods into cfn/builder/helpers.rb or that area.
    def parent_template_path
      "#{templates_folder}/parent.yml"
    end

    # consider moving these methods into cfn/builder/helpers.rb or that area.
    def api_gateway_template_path
      "#{templates_folder}/api-gateway.yml"
    end

    def api_deployment_template_path
      "#{templates_folder}/api-deployment.yml"
    end

    def api_mapping_template_path
      "#{templates_folder}/api-mapping.yml"
    end

    def shared_resources_template_path
      "#{templates_folder}/shared-resources.yml"
    end

    def parent_stack_name
      Jets.project.namespace
    end

    def gateway_api_name
      Jets.project.namespace
    end

    def authorizer_template_path(path)
      underscored = underscore(path)
      underscored.sub!(/^app-/, "")
      "#{templates_folder}/#{underscored}.yml"
    end

    def underscore(s)
      s.to_s.underscore.sub(/\.rb$/, "").tr("/", "-")
    end
  end
end
