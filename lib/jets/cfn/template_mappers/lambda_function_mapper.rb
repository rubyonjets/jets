class Jets::Cfn::TemplateMappers
  class LambdaFunctionMapper
    def initialize(task)
      @task = task
      @app_class = task.class_name.to_s
      # @app_class examples: PostsController, HardJob, Hello, HelloFunction
    end

    # Example: SleepJobPerformLambdaFunction
    def logical_id
      "#{class_action}LambdaFunction".gsub('::','')
    end

    def environment
      env = Jets.config.environment ? Jets.config.environment.to_h : {}
      env.deep_merge(JETS_ENV: Jets.env.to_s)
    end

    # Example: PostsControllerIndex or SleepJobPerform
    def class_action
      "#{@app_class}_#{@task.meth}".camelize
    end

    # Examples:
    #   "#{Jets.config.project_namespace}-sleep_job-perform"
    #   "demo-dev-sleep_job-perform"
    def function_name
      # Example values:
      #   @app_class: admin/pages_controller
      #   @task.meth: index
      method = @app_class.underscore
      # method: admin/pages_controller
      method = method.sub('/','-') + "-#{@task.meth}"
      # method: admin-pages_controller-index
      "#{Jets.config.project_namespace}-#{method}"
    end

    def handler
      handler_value(@task.meth)
    end

    def handler_value(meth)
      "handlers/#{@task.type.pluralize}/#{@app_class.underscore}.#{meth}"
    end

    # def poly_handler_value(handler_function)
    #   folder = @app_class.underscore.split('_')[0..-2].join('_') # remove _controller, _job or _rule
    #   "handlers/#{@task.type.pluralize}/#{folder}/#{@task.meth}.#{handler_function}"
    # end

    def poly_handler_value(handler_function)
      "#{poly_handler_base_path}.#{handler_function}"
    end

    def poly_handler_path
      "#{poly_handler_base_path}#{@task.lang_ext}"
    end

    def poly_handler_base_path
      folder = @app_class.underscore
      "handlers/#{@task.type.pluralize}/#{folder}/#{@task.meth}"
    end
    private :poly_handler_base_path

    def code_s3_key
      Jets::Naming.code_s3_key
    end
  end
end
