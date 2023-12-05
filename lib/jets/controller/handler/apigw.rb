require 'base64'

# Also, logic in the opposite direction: Jets::Controller::Middleware::Mimic::Apigw
# Only called by AWS Lambda before it runs through the middlewares.
module Jets::Controller::Handler
  class Apigw
    extend Memoist

    attr_reader :event, :context, :controller, :meth, :rack_env
    def initialize(event, context, controller, meth, rack_env)
      @event = event
      @context = context
      @controller = controller
      @meth = meth
      @rack_env = rack_env
    end

    # 1. Convert API Gateway event event to Rack env
    # 2. Process using full Rack middleware stack
    # 3. Convert back to API gateway response structure payload
    #
    # Returns back API Gateway response hash structure
    # Only called when running in AWS Lambda.
    #
    # Set the jets.* env variables so we have access to them in the middleware.
    # The controller instance is called in the Main middleware.
    # On AWS, will use original event and context.
    # On local server, will use Middleware::Mimic event and context.
    def process_through_middlewares
      env = rack_env.merge(
        'jets.controller' => @controller, # original controller instance from handler
        'jets.context'    => @context,    # original AWS Lambda context
        'jets.event'      => @event,      # original AWS Lambda event
        'jets.meth'       => @meth,
      )
      status, headers, body = Jets.application.call(env) # goes through full middleware stack
      # middleware can handle Array or BodyProxy, APIGW require Strings
      case body
      when Rack::Files::Iterator
        str = File.read(body.path)
      else
        # join for Rack::BodyProxy or Array
        str = body.join
      end
      convert_to_api_gateway(status, headers, str)
    end

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
  end
end
