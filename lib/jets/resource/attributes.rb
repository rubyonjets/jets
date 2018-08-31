module Jets::Resource
  class Attributes
    extend Memoist

    def initialize(data, task)
      @data = data
      @task = task
    end

    def logical_id
      id = @data.keys.first
      id = replace_value(id, replacements)
      Jets::Pascalize.pascalize_string(id)
    end

    def type
      attributes['Type']
    end

    def properties
      attributes['Properties']
    end

    def attributes
      attributes = @data.values.first
      result = Jets::Pascalize.pascalize(attributes)
      replace_placeholders(result)
    end

    ####################################################
    def replacements
      # mapper = Mapper.new(@task)
      # mapper.replacements

      # lambda_function_map = Jets::Cfn::TemplateMappers::LambdaFunctionMapper.new(@task)
      function_logical_id = "#{class_action}LambdaFunction".gsub('::','')
      rule_target_id = "#{full_task_name}RuleTarget"

      permission_logical_id = "#{class_action}EventsRulePermission".gsub('::','')
      source_arn = "#{class_action}ScheduledEvent"
      # rule_target_id = "#{full_task_name}RuleTarget"
      {
        # creator.resource
        "LAMBDA_FUNCTION_ARN": "!GetAtt #{function_logical_id}.Arn",
        "RULE_TARGET_ID": rule_target_id,
        # creator.resource.permission
        "LAMBDA_PERMISSION_ARN": "!GetAtt #{permission_logical_id}.Arn",
        "SOURCE_ARN": "!GetAtt #{source_arn}.Arn",
      }
    end
    memoize :replacements

    # Example: PostsControllerIndex or SleepJobPerform
    def class_action
      "#{@app_class}_#{@task.meth}".camelize
    end

    # Full camelized task name including the class
    # Example: HardJobDig
    def full_task_name
      class_name = @task.class_name.gsub('::','')
      task_name = @task.meth.to_s.camelize
      "#{class_name}#{task_name}"
    end

  private

    # Replace placeholder values like LAMBDA_FUNCTION_ARN with actual values.
    # Usage:
    #
    #   replace_placeholders(LAMBDA_FUNCTION_ARN: "blah:arn")
    #
    def replace_placeholders(resource)
      update_values(resource, replacements)
    end

    def update_values(original, replacements={})
      case original
      when Array
        original.map { |v| update_values(v, replacements) }
      when Hash
        initializer = original.map do |k, v|
          [k, update_values(v, replacements)]
        end
        Hash[initializer]
      else
        replace_value(original, replacements)
      end
    end

    def replace_value(text, replacements={})
      replacements.each do |k,v|
        text = text.to_s.gsub(k.to_s,v)
      end
      text
    end
  end
end
