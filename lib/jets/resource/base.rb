class Jets::Resource
  class Base
    extend Memoist
    delegate :logical_id, :type, :properties, :attributes, :outputs,
             to: :resource

    # Usually overridden
    def initialize
      @definition = definition
      @replacements = replacements
    end

    def resource
      Jets::Resource.new(definition, replacements)
    end
    memoize :resource

    def replacements
      {}
    end
  end
end
