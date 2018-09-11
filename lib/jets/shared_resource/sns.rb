class Jets::SharedResource
  class Sns < Base
    def topic(*args)
      definition = standardize_definition(*args)

      resource = Jets::Resource::Sns::Topic.new(@shared_class, definition)
      Jets::SharedResource.register_resource(resource)
      resource
    end
  end
end