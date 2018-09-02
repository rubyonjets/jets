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
      # TODOs:
      # * fill out these maps for jets native supported resources.
      # * connect a plugin to figure out interface.
      # * add ability to explicitly override principal and source_arn.
      def replacer_map
        {
          "AWS::Config::ConfigRule" => "Jets::Resource::Replacer::ConfigRule"
        }
      end

      def principal_map
        {
          "AWS::Events::Rule" => "events.amazonaws.com",
          "AWS::Config::ConfigRule" => "config.amazonaws.com",
        }
      end
    end
  end
end
