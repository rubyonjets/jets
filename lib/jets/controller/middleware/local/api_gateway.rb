# Takes a Rack env and converts to ApiGateway event
class Jets::Controller::Middleware::Local
  class ApiGateway
    extend Memoist

    def initialize(route, env)
      @route, @env = route, env
    end

    def event
      resource = @route.path(:api_gateway) # posts/{id}/edit
      path = @env['PATH_INFO'].sub('/','') # remove beginning slash
      {
        "resource" => "/#{resource}", # "/posts/{id}/edit"
        "path" => @env['PATH_INFO'],  # /posts/tung/edit
        "httpMethod" => @env['REQUEST_METHOD'], # GET
        "headers" => request_headers,
        "queryStringParameters" => query_string_parameters,
        "pathParameters" => @route.extract_parameters(path),
        "stageVariables" => nil,
        "requestContext" => {},
        "body" => get_body,
        "isBase64Encoded" => false,
      }
    end
    memoize :event

    # Annoying. The headers part of the AWS Lambda proxy structure
    # does not consisently use the same casing scheme for the header keys.
    # Sometimes it looks like this:
    #   Accept-Encoding
    # and sometimes it looks like this:
    #   cache-control
    # Map for special cases when the casing doesn't match.
    CASING_MAP = {
      "Cache-Control" => "cache-control",
      "Content-Type" => "content-type",
      "Origin" => "origin",
      "Upgrade-Insecure-Requests" => "upgrade-insecure-requests",
    }

    # Map rack env headers to Api Gateway event headers. Most rack env headers are
    # prepended by HTTP_.
    #
    # Some API Gateway Lambda Proxy are also in the rack env headers. Example:
    #
    #   "X-Amz-Cf-Id": "W8DF6J-lx1bkV00eCiBwIq5dldTSGGiG4BinJlxvN_4o8fCZtbsVjw==",
    #   "X-Amzn-Trace-Id": "Root=1-5a0dc1ac-58a7db712a57d6aa4186c2ac",
    #   "X-Forwarded-For": "88.88.88.88, 54.239.203.117",
    #   "X-Forwarded-Port": "443",
    #   "X-Forwarded-Proto": "https",
    #
    # For sample dump of the event headers, check out:
    #   spec/fixtures/samples/event-headers-form-post.json
    #
    # We generally do add those API Gateway Lambda specific headers because
    # they would be fake anyway and by not adding them we can distinguish a
    # local request from a remote request on API Gateway.
    def request_headers
      headers = @env.select { |k,v| k =~ /^HTTP_/ }.inject({}) do |h,(k,v)|
          # map things like HTTP_USER_AGENT to "User-Agent"
          key = k.sub('HTTP_','').split('_').map(&:capitalize).join('-')
          h[key] = v
          h
        end
      # Content type is not prepended with HTTP_
      headers["Content-Type"] = @env["CONTENT_TYPE"] if @env["CONTENT_TYPE"]

      # Adjust the casing so it matches the Lambda AWS Proxy structure
      CASING_MAP.each do |nice_casing, bad_casing|
        if headers.key?(nice_casing)
          headers[bad_casing] = headers.delete(nice_casing)
        end
      end

      headers
    end

    def query_string_parameters
      Rack::Utils.parse_nested_query(@env['QUERY_STRING'])
    end

    # To get the post body:
    #   rack.input: #<StringIO:0x007f8ccf8db9a0>
    def get_body
      input = @env["rack.input"] || StringIO.new
      body = input.read
      input.rewind # IMPORTANT or else it screws up other middlewares that use the body
      # return nil for blank string, because Lambda AWS_PROXY does this
      body unless body.empty?
    end
  end
end
