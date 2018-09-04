class Jets::Resource
  extend Memoist
  autoload :Replacer, 'jets/resource/replacer'
  autoload :Permission, 'jets/resource/permission'
  autoload :Route, 'jets/resource/route'
  autoload :Cors, 'jets/resource/cors'

  def initialize(definition, replacements={})
    @definition = definition
    @replacements = replacements
  end

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

  def permission
    Permission.new(@replacements, self)
  end
  memoize :permission

  def replacer
    Replacer.new(@replacements)
  end
  memoize :replacer
end
