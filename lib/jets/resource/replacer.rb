class Jets::Resource
  class Replacer
    autoload :Base, 'jets/resource/replacer/base'
    autoload :ConfigRule, 'jets/resource/replacer/config_rule'
    # TODO: handle autoloading for plugins

    class << self
      # TODO: dont really need this lookup anymore
      def lookup(definition)
        Jets::Resource::Replacer::Base

        # keeping logic around just in case but will delete shortly
        # attributes = Jets::Pascalize.pascalize(definition.values.first)
        # type = attributes['Type']
        # klass = replacer_map[type] || "Jets::Resource::Replacer::Base"
        # klass.constantize
      end

      # Examples:
      #   "AWS::Events::Rule" => "events.amazonaws.com",
      #   "AWS::Config::ConfigRule" => "config.amazonaws.com",
      #   "AWS::ApiGateway::Method" => "apigateway.amazonaws.com"
      def principal_map(type)
        service = type.split('::')[1].downcase
        "#{service}.amazonaws.com"
      end

      def source_arn_map(type)
        map = {
          "AWS::ApiGateway::Method" => "!Sub arn:aws:execute-api:${AWS::Region}:${AWS::AccountId}:${RestApi}/*/*",
        }
        map[type]
      end
    end
  end
end
