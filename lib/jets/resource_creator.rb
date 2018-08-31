class Jets::ResourceCreator
  extend Memoist

  def initialize(definition)
    @definition = definition
  end

  # Template snippet that gets injected into the CloudFormation template.
  def resource
    Jets::Pascalize.pascalize(@definition)
  end
  memoize :resource

  # Replace placeholder values like LAMBDA_FUNCTION_ARN with actual values.
  # Usage:
  #
  #   replace_placeholders(LAMBDA_FUNCTION_ARN: "blah:arn")
  #
  def replace_placeholders(replacements={})
    update_values(resource, replacements)
  end

  def update_values(original, replacements={})
    case original
    when Array
      original.map { |v| update_values(v, replacements) }
    when Hash
      initializer = original.map do |k, v|
        [k, update_values(v, replacements)]
      end
      Hash[initializer]
    else
      replace_value(original, replacements)
    end
  end

  def replace_value(text, replacements={})
    replacements.each do |k,v|
      text = text.to_s.gsub(k.to_s,v)
    end
    text
  end
end
