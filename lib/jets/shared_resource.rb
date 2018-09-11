module Jets
  class SharedResource
    autoload :Base, 'jets/shared_resource/base'
    autoload :Sns, 'jets/shared_resource/sns'

    class << self
      def build?
        true # always true, checked by cfn/builders/interface.rb
      end

      def sns
        Sns.new(self)
      end

      @@resources = []
      def register_resource(resource)
        @@resources << resource
      end

      def resources
        @@resources
      end

      # @@resources = {}
      # def register_resource(shared_class, definition)
      #   @@resources[shared_class.to_s] ||= []
      #   @@resources[shared_class.to_s] << definition
      # end

      # def resources
      #   @@resources
      # end
    end
  end
end