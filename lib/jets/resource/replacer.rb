module Jets::Resource
  module Replacer
    autoload :Base, 'jets/resource/replacer/base'
    autoload :ConfigRule, 'jets/resource/replacer/config_rule'
    # TODO: handle autoloading for plugins

    class << self
      def lookup(type)
        klass = replacer_map[type] || "Jets::Resource::Replacer::Base"
        klass.constantize
      end

      # Maps
      # TODO: get rid of this map, and use a convention
      # * connect a plugin to figure out interface.
      # * add ability to explicitly override principal and source_arn.
      def replacer_map
        {
          "AWS::Config::ConfigRule" => "Jets::Resource::Replacer::ConfigRule"
        }
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
