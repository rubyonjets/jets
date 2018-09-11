module Jets
  class Resources
    class << self
      def exists?
        true # TODO: remove this hardcode
      end

      def sns_topic(definition={})
        resource = Jets::Resource::Sns::Topic.new(definition)
        puts "resource.definition: #{resource.definition.inspect}"
      end
    end
  end
end