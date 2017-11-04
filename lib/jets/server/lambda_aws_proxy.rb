Jets.boot # need the project app code
require 'cgi'
require 'stringio'

class Jets::Server
  # This doesnt really need to be middleware
  class LambdaAwsProxy
    def initialize(route, env)
      @route = route
      @env = env
    end

    def response
      event = build_event
      context = {}

      controller_class = find_controller_class
      controller_action = find_controller_action
      # controller = PostsController.new(event, content)
      # resp = controller.edit
      controller = controller_class.new(event, context)
      resp = controller.send(controller_action)

      # Map lambda proxy response format to rack format
      status = resp[:statusCode]
      headers = resp[:headers] || {}
      headers = {'Content-Type' => 'text/html'}.merge(headers)
      body = resp[:body]

      [status, headers, [body]]
    end

    def build_event
      resource = @route.path(true) # posts/{id}/edit
      path = @env['PATH_INFO'].sub('/','') # remove beginning space
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

    def request_headers
      @env.select { |k,v| k =~ /^HTTP_/ }.inject({}) do |h,(k,v)|
        key = k.sub('HTTP_','').split('_').map(&:capitalize).join('-')
        h[key] = v
        h
      end
    end

    def query_string_parameters
      Rack::Utils.parse_nested_query(@env['QUERY_STRING'])
    end

    # To get the post body:
    #   rack.input: #<StringIO:0x007f8ccf8db9a0>
    def get_body
      # @env["rack.input"] should always in there and we should make the tests
      # always rack.input but handling it this way because it's simpler
      input = @env["rack.input"] || StringIO.new
      body = input.read
      # return nil for blank string, because thats what Lambda AWS_PROXY does
      body unless body.empty?
    end

    def find_controller_class
      # posts#edit => PostsController
      @route.controller_name.constantize
    end

    def find_controller_action
      @route.action_name
    end
  end
end
