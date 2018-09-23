# Implements:
#
#   template - uses @definition to build a CloudFormation template section
#
class Jets::Stack
  class Resource
    autoload :Dsl, "jets/stack/resource/dsl"
    include Definition

    def template
      template = camelize(standarize(@definition))
      template = replace_placeholers(template)
      template
    end

    # CloudFormation Resources reference: https://amzn.to/2NKg6ip
    def standarize(definition)
      Jets::Resource::Standardizer.new(definition).template
    end

    def replace_placeholers(template)
      attributes = template.values.first
      s3_key = attributes.dig('Properties','Code','S3Key')
      if s3_key == "code_s3_key_placeholder"
        attributes['Properties']['Code']['S3Key'] = Jets::Naming.code_s3_key
      end
      template
    end
  end
end
