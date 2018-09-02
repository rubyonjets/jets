module Jets::Resource
  module Replacer
    autoload :Base, 'jets/resource/replacer/base'
    autoload :ConfigRule, 'jets/resource/replacer/config_rule'
    # TODO: handle autoloading for plugins

    class << self
      # Plugin registration future use
      def map_registry
        {
          "AWS::Config::ConfigRule" => "Jets::Resource::Replacer::ConfigRule"
        }
      end

      def lookup(type)
        klass = map_registry[type] || "Jets::Resource::Replacer::Base"
        klass.constantize
      end
    end
  end
end
