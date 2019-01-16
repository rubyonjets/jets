class Jets::Resource::ApiGateway::RestApi::Routes
  class Base
    extend Memoist
    include Jets::AwsServices

    def new_routes
      Jets::Router.routes
    end
    memoize :new_routes
  end
end