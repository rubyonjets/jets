# Takes a Rack env and converts to ApiGateway event
# This runs only locally, when not on AWS Lambda
# Note: Logic in the opposite direction: Jets::Controller::Handler::Apigw#rack_vars
class Jets::Controller::Middleware::Mimic
  class Apigw
    extend Memoist

    def initialize(route, env)
      @route, @env = route, env
    end

    # Actual controller instance
    def controller
      controller_class = @route.controller_name.constantize
      meth = @route.action_name
      # must keep the same env as @env, rack env, else constraint lambda proc request will be different
      controller_class.new(event, context, meth, @env)
    end
    memoize :controller # for same object_id in case apigw.controller is called twice

    def meth
      @route.action_name
    end
    memoize :meth

    def context
      LambdaContext.new
    end
    memoize :context

    def event
      resource = @route.path(:api_gateway) # /posts/{id}/edit
      path = @env['PATH_INFO'].sub('/','') # remove beginning slash
      {
        "resource" => resource, # "/posts/{id}/edit"
        "path" => @env['PATH_INFO'],  # /posts/tung/edit
        "httpMethod" => @env['REQUEST_METHOD'], # GET
        "headers" => request_headers,
        "queryStringParameters" => query_string_parameters,
        "multiValueQueryStringParameters" => multi_value_query_string_parameters,
        "pathParameters" => @route.extract_parameters(path),
        "stageVariables" => nil,
        "requestContext" => {},
        "body" => get_body,
        "isBase64Encoded" => false,
      }
    end
    memoize :event
    alias convert event

    protected
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
      # @env['QUERY_STRING']&.split('&')&.each_with_object({}) do |parameter, hash|
      #   key, value = parameter.split('=')
      #   hash[key] = value
      # end || {}
    end
    alias multi_value_query_string_parameters query_string_parameters

    # def multi_value_query_string_parameters
    #   @env['QUERY_STRING']&.split('&')&.each_with_object({}) do |parameter, hash|
    #     key, value = parameter.split('=')
    #     hash[key] = [] if hash[key].nil?
    #     hash[key] << value
    #   end || {}
    # end

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
