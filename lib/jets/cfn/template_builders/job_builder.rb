class Jets::Cfn::TemplateBuilders
  class JobBuilder < BaseChildBuilder
    def compose
      add_common_parameters
      add_functions
      add_resources
    end

    #
    def add_resources
      @app_klass.tasks.each do |task|
        task.resources.each do |definition|
          creator = Jets::Resource::Creator.new(definition, task)
          add_associated_resource(creator.resource)
          add_associated_resource(creator.permission.resource)
        end
      end
    end

    def add_associated_resource(resource)
      add_resource(resource.logical_id, resource.type, resource.properties)
    end
  end
end
