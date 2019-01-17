class Jets::Resource::ApiGateway::RestApi::Routes::Collision
  class VariableException < RuntimeError
    def initialize(message="Route variable collisions")
      super(message)
    end
  end
end
