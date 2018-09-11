module Jets
  class SharedResource
    class << self
      def exists?
        true # TODO: remove this hardcode
      end

      # TODO: move into module and add namespacing
      def sns_topic(logical_id, properties={})
        definition = {
          logical_id => {
            type: "AWS::Sns::Topic",
            properties: properties
          }
        }
        resource = Jets::Resource::Sns::Topic.new(definition)
        puts "resource.definition:".colorize(:cyan)
        pp resource.definition
        nil
      end
    end
  end
end