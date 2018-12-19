class Jets::Resource
  extend Memoist

  autoload :ApiGateway, 'jets/resource/api_gateway'
  autoload :Associated, 'jets/resource/associated'
  autoload :Base, 'jets/resource/base'
  autoload :ChildStack, 'jets/resource/child_stack'
  autoload :Config, 'jets/resource/config'
  autoload :Events, 'jets/resource/events'
  autoload :Iam, 'jets/resource/iam'
  autoload :Lambda, 'jets/resource/lambda'
  autoload :Permission, 'jets/resource/permission'
  autoload :Replacer, 'jets/resource/replacer'
  autoload :Route53, 'jets/resource/route53'
  autoload :S3, 'jets/resource/s3'
  autoload :Sns, 'jets/resource/sns'
  autoload :Sqs, 'jets/resource/sqs'
  autoload :Standardizer, 'jets/resource/standardizer'

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
    Jets::Camelizer.camelize(id)
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
