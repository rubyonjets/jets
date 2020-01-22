class Jets::Resource
  extend Memoist

  attr_reader :definition, :replacements
  def initialize(definition, replacements={})
    @definition = definition
    @replacements = replacements
  end

  def template
    standarize(definition)
  end
  memoize :template

  # CloudFormation Resources reference: https://amzn.to/2NKg6ip
  def standarize(*definition)
    Standardizer.new(definition).template
  end

  def logical_id
    id = template.keys.first
    # replace possible {namespace} in the logical id
    id = replacer.replace_value(id)
    id = Jets::Camelizer.camelize(id)

    Jets::Resource.truncate_id(id)
  end

  def self.truncate_id(id, postfix = '')
    # Api Gateway resource name has a limit of 64 characters.
    # Yet it throws not found when ID is longer than 62 characters and I don't know why.
    # To keep it safe, let's stick to the 62 characters limit.
    if id.size + postfix.size > 62
      "#{id[0..(55 - postfix.size)]}#{Digest::MD5.hexdigest(id)[0..5]}#{postfix}"
    else
      "#{id}#{postfix}"
    end
  end

  def type
    attributes['Type']
  end

  def properties
    attributes['Properties']
  end

  def attributes
    attributes = template.values.first
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
