class Jets::Cfn::TemplateMappers
  class LambdaFunctionMapper
    attr_reader :process_type_class # Example: PostsController or SleepJob
    def initialize(process_type_class, method_name)
      @process_type_class, @method_name = process_type_class.to_s, method_name
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
      "#{@process_type_class}_#{@method_name}".camelize
    end

    # Examples:
    #   "#{Jets.config.project_namespace}-sleep_job-perform"
    #   "demo-dev-sleep_job-perform"
    def function_name
      # @process_type_class: admin/pages_controller
      # @@method_name: index
      method = @process_type_class.underscore
      # method: admin/pages_controller
      method = method.sub('/','-') + "-#{@method_name}"
      # method: admin-pages_controller-index
      "#{Jets.config.project_namespace}-#{method}"
    end

    def handler
      regexp = Regexp.new(process_type.camelize) # IE: Controller or Job
      underscored = @process_type_class.to_s.sub(regexp,'').underscore
      "handlers/#{process_type.pluralize}/#{underscored}.#{@method_name}"
    end

    # controller or job
    def process_type
      process_type_class.underscore.split('_').last
    end

    def code_s3_key
      Jets::Naming.code_s3_key
    end
  end
end
