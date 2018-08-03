require 'rack'
require 'rack/server'
require "jets/server/webpacker_setup" if Jets.webpacker?

class Jets::Server
  autoload :RouteMatcher, "jets/server/route_matcher"
  autoload :TimingMiddleware, "jets/server/timing_middleware"
  autoload :ApiGateway, "jets/server/api_gateway"
  autoload :LambdaAwsProxy, "jets/server/lambda_aws_proxy"

  # Use by Jets::Application
  # Where config.ru in the project leads to.
  def self.call(env)
    ApiGateway.call(env)
  end
end
