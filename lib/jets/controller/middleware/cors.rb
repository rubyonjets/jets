# The rack cors middleware handles all types of requests locally, this includes the OPTIONS request.
# Remotely on lambda, the rack cors middleware handles all requests except the OPTIONS request.
# The options request is handled by a OPTIONS API Gateway Method Mock. This is to allow it to bypass
# API Gateway authorizers.
module Jets::Controller::Middleware
  class Cors
    extend Memoist

    def initialize(app)
      @app = app
    end

    def call(env)
      if env['REQUEST_METHOD'] == 'OPTIONS'
        return [200, cors_headers(true), StringIO.new]
      end

      status, headers, body = @app.call(env)
      cors_headers.each do |k,v|
        headers[k] ||= v
      end
      [status, headers, body]
    end

    def cors_headers(preflight=false)
      headers = case Jets.config.cors
      when true
        {
          "access-control-allow-origin" => "*", # Required for CORS support to work
          "access-control-allow-credentials" => "true" # Required for cookies, authorization headers with HTTPS
        }
      when String
        {
          "access-control-allow-origin" => Jets.config.cors, # contains Hash with Access-Control-Allow-* values
          "access-control-allow-credentials" => "true" # Required for cookies, authorization headers with HTTPS
        }
      when Hash
        Jets.config.cors # contains Hash with Access-Control-Allow-* values
      else
        {}
      end

      headers.merge!(preflight_headers) if preflight
      headers
    end

  private
    # Preflight OPTIONS request has extra headers.
    # This is only used locally. Remotely on AWS Lambda, OPTIONS requests are handled by an API Gateway Method.
    def preflight_headers
      # FYI: Jets as part of the rack processing normalizes the casing of these headers eventually.
      # IE: Access-Control-Allow-Methods
      default = {
        "access-control-allow-methods" => "DELETE,GET,HEAD,OPTIONS,PATCH,POST,PUT",
        "access-control-allow-headers" => "Content-Type,X-Amz-Date,Authorization,Auth,X-Api-Key,X-Amz-Security-Token,X-Amz-User-Agent",
      }
      Jets.config.cors_preflight || default
    end
  end
end
