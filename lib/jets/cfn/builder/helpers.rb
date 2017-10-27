class Jets::Cfn::Builder
  module Helpers
    def compose
      # meant to be overridden by the concrete class
    end

    def compose!
      compose
      write
    end

    def template
      @template
    end

    def text
      YAML.dump(@template.to_hash)
    end

    def add_resource(logical_id, type, properties)
      options = {
        Type: type,
        Properties: properties
      }
      depends_on = properties.delete(:DependsOn)
      options[:DependsOn] = depends_on if depends_on

      @template[:Resources][logical_id] = options
    end

    def add_parameter(name, options={})
      defaults = { Type: "String" }
      options = defaults.merge(options)
      @template[:Parameters] ||= {}
      @template[:Parameters][name.camelize] = options
    end

    def add_output(name, options={})
      defaults = { Type: "String" }
      options = defaults.merge(options)
      @template[:Outputs] ||= {}
      @template[:Outputs][name.camelize] = options
    end
  end
end