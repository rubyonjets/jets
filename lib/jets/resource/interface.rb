# Common interface when @definition and @replacement.
# If not set then the classs should implement:
#
#  logical_id
#  type
#  properties
#
class Jets::Resource
  module Interface
    extend Memoist

    def logical_id
      id = @definition.keys.first
      # replace possible {namespace} in the logical id
      id = replacer.replace_value(id)
      Jets::Pascalize.pascalize_string(id)
    end

    def type
      attributes['Type']
    end

    def properties
      attributes['Properties']
    end

    def attributes
      attributes = @definition.values.first
      attributes = replacer.replace_placeholders(attributes)
      Jets::Pascalize.pascalize(attributes)
    end

    def replacer
      Replacer.new(@replacements)
    end
    memoize :replacer
  end
end