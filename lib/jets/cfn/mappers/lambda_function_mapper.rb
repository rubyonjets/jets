class Jets::Cfn::Mappers
  class LambdaFunctionMapper
    attr_reader :process_type_class # Example: PostsController or SleepJob
    def initialize(process_type_class, method_name)
      @process_type_class, @method_name = process_type_class.to_s, method_name
    end

    def lambda_function_logical_id
      "#{class_action}LambdaFunction"
    end

    # Example: PostsControllerIndex or SleepJobPerform
    def class_action
      "#{@process_type_class}_#{@method_name}".camelize
    end

    def function_name
      method = "#{@process_type_class}_#{@method_name}".underscore.dasherize
      "#{Jets::Config.project_namespace}-#{method}"
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
