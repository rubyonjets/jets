# Class that inherits Base should implement:
#
#   template - method should use @definition to build a CloudFormation template section
#
class Jets::Stack
  module Base
    extend ActiveSupport::Concern

    def initialize(*definition)
      @definition = definition.flatten
    end

    def register
      self.class.register(*@definition)
    end

    def camelize(attributes)
      Jets::Camelizer.transform(attributes)
    end

    included do
      class << self
        def register(*definition)
          @definitions ||= []
          # Create instance of the CloudFormation section class and register it.  Examples:
          #   Stack::Parameter.new(definition)
          #   Stack::Resource.new(definition)
          #   Stack::Output.new(definition)
          @definitions << new(definition)
        end

        def definitions
          @definitions
        end
      end
    end
  end
end
