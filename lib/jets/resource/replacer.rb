module Jets::Resource
  class Replacer
    def initialize(task)
      @task = task
      @app_class = task.class_name.to_s
    end

    # Replace placeholder hash values with replacements.  This does a deep replacement
    # to the hash values.  The replacement "key" is the string value within the value.
    #
    # Example:
    #
    #   attributes = {whatever: "foo REPLACE_KEY bar" }
    #   replace_placeholders(attributes, REPLACE_KEY: "blah:arn")
    #   => {whatever: "foo blah:arn bar" }
    #
    # Also, we always replace the special {namespace} value in the hash values. Example:
    #
    #   attributes = {whatever: "{namespace}LambdaFunction" }
    #   replace_placeholders(attributes, {})
    #   => {whatever: "foo PostsControllerIndexLambdaFunction bar" }
    #
    def replace_placeholders(attributes, replacements={})
      update_values(attributes, replacements)
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
      text = text.to_s # normalize to String
      # custom replacements
      replacements.each do |k,v|
        text = text.gsub(k.to_s, v)
      end
      # always replace the namespace
      text = text.gsub('{namespace}', namespace)
      text
    end

    # Full camelized namespace
    # Example: HardJobDig, PostsControllerIndex, SleepJobPerform
    def namespace
      class_name = @task.class_name.gsub('::','')
      function_name = @task.meth.to_s.camelize
      "#{class_name}#{function_name}"
    end
  end
end
