#!/usr/bin/env ruby

require 'rack'
require 'rack/server'

class Jets::Server
  autoload :RouteMatcher, "jets/server/route_matcher"
  autoload :TimingMiddleware, "jets/server/timing_middleware"
  autoload :ApiGateway, "jets/server/api_gateway"
  autoload :LambdaAwsProxy, "jets/server/lambda_aws_proxy"

  def self.call(env)
    ApiGateway.call(env)
  end
end
