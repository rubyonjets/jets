class Jets::Resource
  extend Memoist

  autoload :Base, 'jets/resource/base'
  autoload :Replacer, 'jets/resource/replacer'
  autoload :Permission, 'jets/resource/permission'
  autoload :ApiGateway, 'jets/resource/api_gateway'
  autoload :ChildStack, 'jets/resource/child_stack'

  attr_reader :definition, :replacements
  def initialize(definition, replacements={})
    @definition = definition
    @replacements = replacements
  end

  def logical_id
    id = definition.keys.first
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
    attributes = definition.values.first
    attributes = replacer.replace_placeholders(attributes)
    Jets::Pascalize.pascalize(attributes)
  end

  def parameters
    {}
  end

  def outputs
    {}
  end

  def replacer
    Replacer.new(replacements)
  end
  memoize :replacer

  def permission
    Permission.new(replacements, self)
  end
  memoize :permission
end
