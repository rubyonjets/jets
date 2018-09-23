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
    @definition = standarize(definition)
    @replacements = replacements
  end

  # CloudFormation Resources reference: https://amzn.to/2NKg6ip
  def standarize(*definition)
    definition = definition.flatten
    first, second, third, _ = definition
    if definition.size == 1 && first.is_a?(Hash) # long form
      first # pass through
    elsif definition.size == 2 && second.is_a?(Hash) # medium form
      logical_id, attributes = first, second
      attributes.delete(:properties) if attributes[:properties].nil? || attributes[:properties].empty?
      { logical_id => attributes }
    elsif definition.size == 2 && second.is_a?(String) # short form
      logical_id, type = first, second
      { logical_id => {
          type: type
      }}
    elsif definition.size == 3 && (second.is_a?(String) || second.is_a?(NilClass))# short form
      logical_id, type, properties = first, second, third
      template = { logical_id => {
                     type: type
                  }}
      attributes = template.values.first
      attributes[:properties] = properties unless properties.empty?
      template
    else # I dont know what form
      raise "Invalid form provided. definition #{definition.inspect}"
    end
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
