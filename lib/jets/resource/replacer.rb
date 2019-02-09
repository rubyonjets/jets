class Jets::Resource
  class Replacer
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

    def replace_value(value)
      # Dont perform replacement on Integers
      return value if value.is_a?(Integer)
      # return value unless value.is_a?(String) or value.is_a?(Symbol)

      value = value.to_s # normalize to String
      @replacements.each do |k,v|
        # IE: Replaces {namespace} => SecurityJobCheck
        value = value.gsub("{#{k}}", v)
      end
      value
    end

    class << self
      # Examples:
      #   "AWS::Events::Rule" => "events.amazonaws.com",
      #   "AWS::Config::ConfigRule" => "config.amazonaws.com",
      #   "AWS::ApiGateway::Method" => "apigateway.amazonaws.com"
      def principal_map(type)
        service = type.split('::')[1].downcase
        service = special_principal_map(service)
        "#{service}.amazonaws.com"
      end

      def special_principal_map(service)
        # special map
        # s3_event actually uses sns topic events to trigger a Lambda function
        map = { "s3" => "sns" }
        map[service] || service
      end

      # From AWS docs: https://amzn.to/2N0QXQL
      # source_arn is "not supported by all event sources"
      #
      # When it is not available the resource definition should add it.
      def source_arn_map(type)
        map = {
          "AWS::ApiGateway::Method" => "!Sub arn:aws:execute-api:${AWS::Region}:${AWS::AccountId}:${RestApi}/*/*",
        }
        map[type]
      end
    end
  end
end
