module Jets
  class SharedResource
    autoload :Base, 'jets/shared_resource/base'
    autoload :Sns, 'jets/shared_resource/sns'
    autoload :Arn, 'jets/shared_resource/arn'

    class << self
      include Arn

      def build?
        true # always true, checked by cfn/builders/interface.rb
      end

      def sns
        Sns.new(self) # self is the custom resource class. IE: Resource < Jets::Resource
      end

      @@resources = []
      def register_resource(resource)
        @@resources << resource
      end

      def resources
        @@resources
      end
    end
  end
end