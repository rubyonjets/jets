class Jets::Cfn::TemplateBuilders
  class RuleBuilder < BaseChildBuilder
    def compose
      add_common_parameters
      add_functions
      add_resources
    end

    def add_resources
      @app_klass.tasks.each do |task|
        # puts "task #{task}"
        task.resources.each do |definition|
          # puts "definition #{definition}"
          creator = Jets::Resource::Creator.new(definition, task)
          add_associated_resource(creator.resource)
          add_associated_resource(creator.resource.permission.attributes)
        end
      end

      # Handle config_rules associated with aws managed rules.
      # List of AWS Config Managed Rules: https://amzn.to/2BOt9KN
      @app_klass.managed_rules.each do |rule|
        creator = Jets::Resource::Creator.new(rule[:definition], rule[:task])
        add_associated_resource(creator.resource)
      end
    end

    def add_associated_resource(resource)
      add_resource(resource.logical_id, resource.type, resource.properties)
    end
  end
end

