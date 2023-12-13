require "rack"
require "uri"

module Jets::Shim::Adapter
  # Not named Rack to avoid confusion with the Rack gem
  class Web < Base
    def handle
      env = to_rack_env
      app = Jets::Shim.config.app
      triplet = app.call(env)
      translate_response(triplet)
    end

    def to_rack_env
      rack_env = base_env.merge(env).merge(headers_env)
      rack_env.delete_if { |k, v| v.nil? }
      rack_env
    end

    # Translate rack triplet to compatible response for the service
    def translate_response(triplet)
      adapter_name = self.class.name.split("::").last
      response_class = Jets::Shim::Response.const_get(adapter_name)
      response = response_class.new(triplet)
      response.translate
    end

    # env should be implemented by subclass
    def env
      {}
    end
    private :env

    def headers_env
      env = {}
      headers.each do |k, v|
        key = k.tr("-", "_").upcase
        http_key = "HTTP_#{key}" # IE: User-Agent => HTTP_USER_AGENT

        # specially handle host since it can be overridden with JETS_SHIM_HOST
        next if http_key == "HTTP_HOST"

        if special_headers.include?(key)
          env[special_headers[key]] = v
        else
          env[http_key] ||= v
        end
      end
      env
    end

    def special_headers
      # Note: apigw does not have content-length in headers.
      # See: https://stackoverflow.com/questions/56693981/how-do-i-get-http-header-content-length-in-api-gateway-lambda-proxy-integratio
      #
      # Instead content-length must be calculated from body. Done in base_env.
      # Adding content-length here for other adapters.
      # Headers have highest precedence since they get merged last.
      {
        "CONTENT_TYPE" => "CONTENT_TYPE",
        "CONTENT_LENGTH" => "CONTENT_LENGTH"
      }
    end

    def base_env
      # 'rack.input' - Even if not set, Rack always assigns an StringIO.
      {
        "CONTENT_LENGTH" => content_length,
        "HTTP_COOKIE" => http_cookie,
        "lambda.context" => context,
        "lambda.event" => event,
        "rack.input" => StringIO.new(body || ""),
        "REMOTE_ADDR" => remote_addr,
        "REMOTE_HOST" => host,
        "REQUEST_URI" => request_uri
      }
    end

    # https://docs.aws.amazon.com/lambda/latest/dg/urls-invocation.html
    # https://docs.aws.amazon.com/apigateway/latest/developerguide/http-api-develop-integrations-lambda.html#http-api-develop-integrations-lambda.proxy-format
    def http_cookie
      event["cookies"]&.join("; ")
    end

    def remote_addr
      # X-Forwarded-For: client, proxy1, proxy2
      # X-Forwarded-For:
      #   The originating IP address of the client connecting to the ALB.
      #   This is used to capture the client IP address for requests that are sent to a proxy chain or a load balancer
      #   before they reach your server.
      #   If the X-Forwarded-For header is not present in the request, the remote IP address from the transport layer,
      #   such as the TCP connection, is used instead.
      #   https://docs.aws.amazon.com/elasticloadbalancing/latest/application/load-balancer-access-logs.html#access-log-entry-format
      addr = headers["X-Forwarded-For"] || headers["x-forwarded-for"] || headers["REMOTE_ADDR"]
      addr.split(",").first.strip if addr
    end

    def content_length
      bytesize = body.bytesize.to_s if body
      headers["Content-Length"] || bytesize
    end

    def request_uri
      # IE: /foo?bar=1
      "#{path_info}?#{query_string}"
    end

    # Decoding base64 from API Gateaway if necessary
    # Rack will be none the wiser
    def body
      if event["isBase64Encoded"]
        Base64.decode64(event["body"])
      else
        event["body"]
      end
    end

    def headers
      event["headers"] || {}
    end

    def host
      # Host: apigw
      # host: lambda and alb
      ENV["JETS_SHIM_HOST"] ||
        shim_host ||
        headers["Host"] ||
        headers["host"]
    end

    # Can be added by CloudFront function
    # Also, POST requests have an origin header. IE: Updating a record with CRUD.
    def shim_host
      return unless headers["jets-shim-host"]
      URI.parse(headers["jets-shim-host"]).host
    end

    def https
      # X-Forwarded-Proto: apigw
      # x-forwarded-proto: lambda and alb
      proto = headers["X-Forwarded-Proto"] || headers["x-forwarded-proto"]
      (proto == "https") ? "on" : "off"
    end
  end
end
