require 'base64'

module Jets::Controller::Rack
  class Adapter
    extend Memoist

    # Returns back API Gateway response hash structure
    def self.process(event, context)
      adapter = new(event, context)
      adapter.process
    end

    def initialize(event, context)
      @event, @context = event, context
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

      {}.tap do |resp|
        resp['statusCode'] = status
        resp['body'] = body
        resp['isBase64Encoded'] = base64
        add_response_headers(resp, headers)
        adjust_for_elb(resp)
      end
    end

    def add_response_headers(resp, headers)
      resp['headers'] = headers.reject { |_, val| val.is_a?(Array) }
      multi_value_headers = headers.select { |_, val| val.is_a?(Array) }

      resp['multiValueHeaders'] = multi_value_headers unless multi_value_headers.blank?
    end

    # Note: ELB is not officially support. This is just in case users wish to manually
    # connect ELBs to the functions created by Jets.
    def adjust_for_elb(resp)
      return resp unless from_elb?

      # ELB requires statusCode to be an Integer whereas API Gateway requires statusCode to be a String
      status = resp["statusCode"] = resp["statusCode"].to_i

      # ELB also requires statusDescription attribute
      status_desc = Rack::Utils::HTTP_STATUS_CODES[status]
      status_desc = status_desc.nil? ? status.to_s : "#{status} #{status_desc}"
      resp["statusDescription"] = status_desc

      resp
    end

    def from_elb?
      # NOTE: @event["requestContext"]["elb"] is set when the request is coming from an elb
      # Can set JETS_ELB=1 for local testing
      @event["requestContext"] && @event["requestContext"]["elb"] || ENV['JETS_ELB']
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
    # The lambda.* info is used by the Rack::Local middleware to create a mimiced
    # controller for the local server.
    #
    def rack_vars(vars)
      env.merge!(vars)
    end

  end
end
