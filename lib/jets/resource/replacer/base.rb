class Jets::Resource::Replacer
  class Base
    extend Memoist

    def initialize(replacements={})
      @replacements = replacements
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
    def replace_placeholders(attributes)
      update_values(attributes)
    end

    def update_values(original)
      case original
      when Array
        original.map { |v| update_values(v) }
      when Hash
        initializer = original.map do |k, v|
          [k, update_values(v)]
        end
        Hash[initializer]
      else
        replace_value(original)
      end
    end

    def replace_value(text)
      text = text.to_s # normalize to String
      @replacements.each do |k,v|
        # IE: Replaces {namespace} => SecurityJobCheck
        text = text.gsub("{#{k}}", v)
      end
      text
    end
  end
end
