class Jets::Cfn::Builder
  module Helpers
    def add_resource(logical_id, type, properties)
      @template[:Resources][logical_id] = {
        Type: type,
        Properties: properties
      }
    end

    def add_parameter(name, options={})
      defaults = { Type: "String" }
      options = defaults.merge(options)
      @template[:Parameters] ||= {}
      @template[:Parameters][name.camelize] = options
    end
  end
end