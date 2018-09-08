class Jets::Resource
  class Base
    extend Memoist
    delegate :logical_id, :type, :properties, :attributes, :parameters, :outputs,
             to: :resource

    def resource
      Jets::Resource.new(definition, replacements)
    end
    memoize :resource

    def replacements
      @replacements || {}
    end
  end
end
