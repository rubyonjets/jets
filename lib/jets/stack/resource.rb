# Implements:
#
#   template - uses @definition to build a CloudFormation template section
#
class Jets::Stack
  class Resource
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
        checksum = Jets::Builders::Md5.checksums["stage/code"]
        code_zip = "code-#{checksum}.zip"
        attributes['Properties']['Code']['S3Key'] = "jets/code/#{code_zip}"
      end
      template
    end
  end
end
