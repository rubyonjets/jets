class Jets::Resource
  extend Memoist

  autoload :ApiGateway, 'jets/resource/api_gateway'
  autoload :Base, 'jets/resource/base'
  autoload :ChildStack, 'jets/resource/child_stack'
  autoload :Config, 'jets/resource/config'
  autoload :Events, 'jets/resource/events'
  autoload :Function, 'jets/resource/function'
  autoload :Iam, 'jets/resource/iam'
  autoload :Permission, 'jets/resource/permission'
  autoload :Replacer, 'jets/resource/replacer'
  autoload :S3, 'jets/resource/s3'
  autoload :Sns, 'jets/resource/sns'

  attr_reader :definition, :replacements
  def initialize(definition, replacements={})
    @definition = definition
    @replacements = replacements
  end

  def logical_id
    id = definition.keys.first
    # replace possible {namespace} in the logical id
    id = replacer.replace_value(id)
    Jets::Camelizer.camelize(id)
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
    Jets::Camelizer.transform(attributes)
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
