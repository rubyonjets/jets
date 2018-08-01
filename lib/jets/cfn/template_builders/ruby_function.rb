class Jets::Cfn::TemplateBuilders
  class PythonPropertiesBuilder < FunctionPropertiesBuilder
    def properties
      props = super
      
      handler = @task.default_handler[:python]
      
      app_class = @task.class_name.to_s
      underscored = @app_class.underscore
      full_handler = "handlers/#{@task.type.pluralize}/#{underscored}.#{handler}"
      props.merge(
        Runtime: "python3.6",
        Handler: full_handler
      )
    end
  end
end
