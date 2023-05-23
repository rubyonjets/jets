# Classes that inherit from this method should NOT define and override:
#
#   logical_id
#   type
#   properties
#   attributes
#
# These are computed methods that derive their values from the resource definition itself.
# Overriding these methods will remove the computed logical which handles things
# like camelizing and replacements.
module Jets::Cfn
  class Base
    extend Memoist
    include Jets::Util::Camelize

    # interface method
    def replacements
      @replacements || {}
    end

    def replacer
      Resource::Replacer.new(replacements)
    end
    memoize :replacer

    def template
      standarize(definition)
    end
    memoize :template

    # CloudFormation Resources reference: https://amzn.to/2NKg6ip
    def standarize(*definition)
      Resource::Standardizer.new(definition).template
    end

    def logical_id
      id = template.keys.first
      id = replacer.replace_value(id) # IE: replace possible {namespace} in the logical id
      Jets::Camelizer.camelize(id) # logical id limit is 256 chars
    end

    def type
      attributes[:Type]
    end

    def properties
      attributes[:Properties]
    end

    def attributes
      attributes = template.values.first
      attributes = replacer.replace_placeholders(attributes)
      camelize(attributes)
    end

    def parameters
      {}
    end

    def outputs
      {}
    end

    def permission
      Resource::Lambda::Permission.new(replacements, self)
    end
    memoize :permission

    class << self
      def truncate_id(id, postfix = '')
        # Api Gateway resource name has a limit of 64 characters.
        # Yet it throws not found when ID is longer than 62 characters and I don't know why.
        # To keep it safe, let's stick to the 62 characters limit.
        if id.size + postfix.size > 62
          "#{id[0..(55 - postfix.size)]}#{Digest::MD5.hexdigest(id)[0..5]}#{postfix}"
        else
          "#{id}#{postfix}"
        end
      end
    end
  end
end
