require "rack/utils"

# Special renderer.  All the other renderers lead here
module Jets::Controller::Renderers
  class RackRenderer < BaseRenderer
    # Example response:
    #
    #   [200, {"my-header" = > "value" }, "my body" ]
    def render
      # we do some normalization here
      status = map_status_code(@options[:status]) || 200
      status = status.to_s # API Gateway requires a string but rack is okay with either
      body = @options[:body]
      base64 = normalized_base64_option(@options)

      headers = @options[:headers] || {}
      headers = cors_headers.merge(headers)
      headers["Content-Type"] ||= @options[:content_type] || Jets::Controller::DEFAULT_CONTENT_TYPE
      # x-jets-base64 to convert this Rack triplet to a API Gateway hash structure later
      headers["x-jets-base64"] = base64 ? "true" : "false"
      body = StringIO.new(body)
      [status, headers, body] # triplet
    end

    # maps:
    #   :continue => 100
    #   :success => 200
    #   etc
    def map_status_code(code)
      if code.is_a?(Symbol)
        Rack::Utils::SYMBOL_TO_STATUS_CODE[code]
      else
        code
      end
    end

    def normalized_base64_option(options)
      base64 = @options[:base64] if options.key?(:base64)
      base64 = @options[:isBase64Encoded] if options.key?(:isBase64Encoded)
      base64
    end

    def cors_headers
      case Jets.config.cors
      when true
        {
          "Access-Control-Allow-Origin" => "*", # Required for CORS support to work
          "Access-Control-Allow-Credentials" => "true" # Required for cookies, authorization headers with HTTPS
        }
      when Hash
        Jets.config.cors # contains Hash with Access-Control-Allow-* values
      else
        {}
      end
    end
  end
end
