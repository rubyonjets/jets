# Special renderer.  All the other renderers lead here
module Jets::Controller::Renderers
  class AwsProxyRenderer < BaseRenderer
    # Transform the structure to AWS_PROXY compatiable structure
    # AWS Docs Output Format of a Lambda Function for Proxy Integration
    # http://docs.aws.amazon.com/apigateway/latest/developerguide/set-up-lambda-proxy-integrations.html#api-gateway-simple-proxy-for-lambda-output-format
    #
    # {statusCode: ..., body: ..., headers: ..., isBase64Encoded: ... }
    def render
      # we do some normalization here
      status = @options[:status] || 200
      headers = @options[:headers] || {}
      headers = cors_headers.merge(headers)
      body = @options[:body]
      base64 = normalized_base64_option(@options)

      if body.is_a?(Hash)
        body = JSON.dump(body) # body must be a String
        headers["Content-Type"] ||= @options[:content_type] || "application/json"
      else
        headers["Content-Type"] ||= @options[:content_type] || "text/html; charset=utf-8"
      end

      # Compatiable Lambda Proxy Hash
      # Explictly assign keys, additional keys will not be compatiable
      resp = {
        "statusCode" => status,
        "headers" => headers,
        "body" => body,
        "isBase64Encoded" => base64,
      }
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
