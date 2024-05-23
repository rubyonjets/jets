require "active_support"
require "active_support/core_ext/string"
require "base64"
require "json"
require "mime/types"
require "rack"

module Jets::Shim::Response
  class Base
    include Jets::Util::Logging
    include Jets::Util::Truthy

    def initialize(triplet)
      @triplet = triplet
    end

    # AWS Lambda proxy integrations 2.0
    # https://docs.aws.amazon.com/lambda/latest/dg/urls-invocation.html
    # https://docs.aws.amazon.com/apigateway/latest/developerguide/http-api-develop-integrations-lambda.html#http-api-develop-integrations-lambda.proxy-format
    def translate
      status, headers, rack_body = @triplet
      headers.merge!(prewarm_headers)
      cookies = handle_set_cookie!(headers)
      stringify_values!(headers)
      body = translate_body(rack_body)
      base64 = base64_encode?(headers)
      if base64
        body = Base64.strict_encode64(body)
      end
      resp = {
        statusCode: status,
        headers: headers, # response headers
        body: body,
        cookies: cookies,
        isBase64Encoded: base64
      }.delete_if { |k, v| v.nil? }
      show_debug_shim_resp(resp)
      resp
    end

    private

    # Example headers:
    # {
    #   "x-jets-prewarm-count"=>1,
    #   "x-jets-prewarm-at"=>"2024-04-18 12:11:37 UTC",
    #   "x-jets-gid"=>"1bd5d993"
    # }
    def prewarm_headers
      Jets::Shim::Adapter::Prewarm.stats.transform_keys { |k| "x-jets-#{k.to_s.dasherize}" }
    end

    def handle_set_cookie!(headers)
      # Interesting: Both headers['Set-Cookie'] and headers['set-cookie'] work.
      # Rack is smart enough to handle both. Also, Rack either returns a String
      # for a single cookie or Array for multiple cookies.
      # Must handle both Set-Cookie and set-cookie Rails seems to be inconsistent
      # Locally: Set-Cookie
      # AWS Lambda: set-cookie
      set_cookie = headers.delete("Set-Cookie") || headers.delete("set-cookie")
      return unless set_cookie

      # AWS Lambda proxy integrations 2.0 requires cookies to be an array
      # https://docs.aws.amazon.com/apigateway/latest/developerguide/http-api-develop-integrations-lambda.html#http-api-develop-integrations-lambda.proxy-format
      if set_cookie.is_a?(String)
        # set_cookie is a single cookie String
        # IE: "yummy_cookie=choco"
        set_cookie.split("\n").map(&:strip)
      else
        # set_cookie is already cookies Array
        # IE: ["yummy_cookie=choco", "tasty_cookie=strawberry"]
        set_cookie
      end
    end

    def stringify_values!(headers)
      headers.each do |k, v|
        headers[k] = v.to_s
      end
      headers
    end

    # Rack middleware handles Array or BodyProxy normally, but APIGW require String
    def translate_body(rack_body)
      case rack_body
      when Rack::Files::Iterator
        # Sinatra does not always send the right content-type header so we check the file extension
        # ActiveStorage does not always have file extensions so will have to check the content-type header also
        @encode_binary = binary?(rack_body.path) # set flag for base64_encode?
        File.read(rack_body.path)
      else # Rack::BodyProxy or Array
        body = "" # String
        rack_body.each { |part| body << part.to_s }
        body
      end
    end

    def binary?(file_path)
      mime_type = MIME::Types.type_for(file_path).first
      mime_type&.binary?
    end

    # Headers or @encode_binary flag is determine if body should be base64 encoded.
    # Note: mime_type.binary? is not always accurate.
    # Example: render json: {ok: true} is not binary but mime_type.binary? is true
    def base64_encode?(headers)
      return @encode_binary if @encode_binary
      if headers.key?("x-jets-base64")
        return truthy?(headers["x-jets-base64"])
      end
      return true if Jets.project.config.base64_encode

      content_type = headers["content-type"]
      if content_type
        mime_type = MIME::Types[content_type].first
        mime_type.encoding == "base64"
      end
    end

    def show_debug_shim_resp(resp)
      Jets::Shim::Handler.show_debug_shim("jets shim response:", resp)
    end
  end
end
