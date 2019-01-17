class Jets::Resource::ApiGateway::RestApi
  class Routes
    autoload :Base, 'jets/resource/api_gateway/rest_api/routes/base'
    autoload :Change, 'jets/resource/api_gateway/rest_api/routes/change'
    autoload :Collision, 'jets/resource/api_gateway/rest_api/routes/collision'

    def self.changed?
      Change.new.changed?
    end
  end
end