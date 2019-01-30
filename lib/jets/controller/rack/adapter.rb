require 'base64'

module Jets::Controller::Rack
  class Adapter
    extend Memoist

    # Returns back API Gateway response hash structure
    def self.process(event, context, meth)
      adapter = new(event, context, meth)
      adapter.process
    end

    def initialize(event, context, meth)
      @event, @context, @meth = event, context, meth
    end

    # 1. Convert API Gateway event event to Rack env
    # 2. Process using full Rack middleware stack
    # 3. Convert back to API gateway response structure payload
    def process
      status, headers, body = Jets.application.call(env)
      convert_to_api_gateway(status, headers, body)
    end

    def env
      Env.new(@event, @context, adapter: true).convert # convert to Rack env
    end
    memoize :env

    # Transform the structure to AWS_PROXY compatible structure
    # http://docs.aws.amazon.com/apigateway/latest/developerguide/set-up-lambda-proxy-integrations.html#api-gateway-simple-proxy-for-lambda-output-format
    def convert_to_api_gateway(status, headers, body)
      base64 = headers["x-jets-base64"] == 'yes'
      body = body.respond_to?(:read) ? body.read : body
      body = Base64.encode64(body) if base64
      {
        "statusCode" => status,
        "headers" => headers,
        "body" => body,
        "isBase64Encoded" => base64,
      }
    end

    # Called from Jets::Controller::Base.process. Example:
    #
    #   adapter.rack_vars(
    #     'jets.controller' => self,
    #     'lambda.context' => context,
    #     'lambda.event' => event,
    #     'lambda.meth' => meth,
    #   )
    #
    # Passes a these special variables so we have access to them in the middleware.
    # The controller instance is called in the Main middleware.
    # The lambda.* info is used by the Rack::Local middleware to create a mimicked
    # controller for the local server.
    #
    def rack_vars(vars)
      env.merge!(vars)
    end

  end
end
