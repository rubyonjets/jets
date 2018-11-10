require 'net/http'
require 'rack'

module Jets::Mega
  class Request
    def initialize(event, controller)
      @event = event
      @controller = controller # Jets::Controller instance
    end

    def proxy
      http_method = @event['httpMethod'] # GET, POST, PUT, DELETE, etc
      params = @controller.params(raw: true, path_parameters: false)

      uri = URI("http://localhost:9292#{@controller.request.path}") # local rack server
      http = Net::HTTP.new(uri.host, uri.port)
      http.open_timeout = 60
      http.read_timeout = 60

      # Rails sets _method=patch or _method=put as workaround
      # Falls back to GET when testing in lambda console
      http_class = params['_method'] || http_method || 'GET'
      http_class.capitalize!

      request_class = "Net::HTTP::#{http_class}".constantize # IE: Net::HTTP::Get
      request = request_class.new(uri.path)
      if %w[Post Patch Put].include?(http_class)
        params = HashConverter.encode(params)
        request.set_form_data(params)
      end

      request = set_headers!(request)

      # Setup body
      env = Jets::Controller::Rack::Env.new(@event, {}).convert # convert to Rack env
      source_request = Rack::Request.new(env)
      if source_request.body.respond_to?(:read)
        request.body = source_request.body.read
        request.content_length = source_request.content_length.to_i
        source_request.body.rewind
      end

      response = http.request(request)

      # TODO: handle binary
      {
        status: response.code.to_i,
        headers: response.each_header.to_h,
        body: response.body,
      }
    end

    # Set request headers. Forwards original request info from remote API gateway.
    # By this time, the server/api_gateway.rb middleware.
    def set_headers!(request)
      headers = @event['headers'] # from api gateway
      if headers # remote API Gateway
        # Forward headers from API Gateway over to the sub http request.
        # It's important to forward the headers. Here are some examples:
        #
        #   "Turbolinks-Referrer"=>"http://localhost:8888/posts/122",
        #   "Referer"=>"http://localhost:8888/posts/122",
        #   "Accept-Encoding"=>"gzip, deflate",
        #   "Accept-Language"=>"en-US,en;q=0.9,pt;q=0.8",
        #   "Cookie"=>"_demo_session=...",
        #   "If-None-Match"=>"W/\"9fa479205fc6d24ca826d46f1f6cf461\"",
        headers.each do |k,v|
          request[k] = v
        end

        # Note by the time headers get to rack later in the they get changed to:
        #
        #   request['X-Forwarded-Host'] vs env['HTTP_X_FORWARDED_HOST']
        #
        request['X-Forwarded-For'] = headers['X-Forwarded-For'] # "1.1.1.1, 2.2.2.2" # can be comma separated list
        request['X-Forwarded-Host'] = headers['Host'] # uhghn8z6t1.execute-api.us-east-1.amazonaws.com
        request['X-Forwarded-Port'] = headers['X-Forwarded-Port'] # 443
        request['X-Forwarded-Proto'] = headers['X-Forwarded-Proto'] # https # scheme
      end

      request
    end
  end
end
