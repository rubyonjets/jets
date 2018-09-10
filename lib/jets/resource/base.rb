# Classes that inherit from this method should NOT define and override:
#
#   logical_id
#   type
#   properties
#   attributes
#
# These are computed methods that derive their values from the resource definition itself.
# Overriding these methods will remove the computed logical which handles things
# like camelizing and replacements.
#
# The implementation of these methods are in `Jets::Resource`.
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
