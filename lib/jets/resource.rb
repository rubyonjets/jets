class Jets::Resource
  extend Memoist
  autoload :Replacer, 'jets/resource/replacer'

  # autoload :Attributes, 'jets/resource/attributes'
  # autoload :Creator, 'jets/resource/creator'
  # autoload :Permission, 'jets/resource/permission'
  # autoload :Route, 'jets/resource/route'

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

  def replacer
    # Use raw @definition to avoid infinite loop from using attributes
    # TODO: dont think there's any infinite loop anymore
    attributes = Jets::Pascalize.pascalize(@definition.values.first)
    type = attributes['Type']
    replacer_class = Replacer.lookup(type)
    replacer_class.new(@replacements)
  end
  memoize :replacer
end
