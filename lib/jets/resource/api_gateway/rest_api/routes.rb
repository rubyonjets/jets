class Jets::Resource::ApiGateway::RestApi
  class Routes
    def self.changed?
      Change.new.changed?
    end
  end
end