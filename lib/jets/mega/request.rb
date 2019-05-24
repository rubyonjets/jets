require 'net/http'
require 'rack'

module Jets::Mega
  class Request
    JETS_OUTPUT = "/tmp/jets-output.log"

    extend Memoist

    def initialize(event, controller)
      @event = event
      @controller = controller # Jets::Controller instance
    end

    def proxy
      http_method = @event['httpMethod'] # GET, POST, PUT, DELETE, etc
      params = @controller.params(raw: true, path_parameters: false)

      uri = get_uri

      http = Net::HTTP.new(uri.host, uri.port)
      http.open_timeout = http.read_timeout = 60

      # Rails sets _method=patch or _method=put as workaround
      # Falls back to GET when testing in lambda console
      http_class = params['_method'] || http_method || 'GET'
      http_class.capitalize!

      request_class = "Net::HTTP::#{http_class}".constantize # IE: Net::HTTP::Get
      request = request_class.new(uri)

      # Set form data
      if %w[Post Patch Put].include?(http_class)
        params = HashConverter.encode(params)
        request.set_form_data(params)
      end

      # Set body info
      request.body = source.body
      request.content_length = source.content_length

      # Need to set headers after body and form_data for some reason
      request = set_headers!(request)

      # Make request
      response = http.request(request)

      puts_rack_output

      status = response.code.to_i
      headers = response.each_header.to_h
      encoding = get_encoding(headers['content-type'])
      body = response.body&.force_encoding(encoding)
      {
        status: status,
        headers: headers,
        body: body,
      }
    end

    def get_encoding(content_type)
      default = Jets.config.encoding.default
      return default unless content_type

      md = content_type.match(/charset=(.+)/)
      return default unless md

      md[1]
    end

    # Grab the rack output from the /tmp/jets-output.log and puts it back in the
    # main process' stdout
    def puts_rack_output
      return unless File.exist?(JETS_OUTPUT)
      puts IO.readlines(JETS_OUTPUT)
      File.truncate(JETS_OUTPUT, 0)
    end

    def get_uri
      url = "http://localhost:9292#{@controller.request.path}" # local rack server
      unless @controller.query_parameters.empty?
        # Thanks: https://stackoverflow.com/questions/798710/ruby-how-to-turn-a-hash-into-http-parameters
        query_string = Rack::Utils.build_nested_query(@controller.query_parameters)
        url += "?#{query_string}"
      end
      URI(url)
    end

    def source
      Source.new(@event)
    end
    memoize :source

    # Rails sets _method=patch or _method=put as workaround
    # Falls back to GET when testing in lambda console
    # @event['httpMethod'] is GET, POST, PUT, DELETE, etc
    def http_class
      http_class = params['_method'] || @event['httpMethod'] || 'GET'
      http_class.capitalize!
      http_class
    end

    def params
      @controller.params(raw: true, path_parameters: false, body_parameters: true)
    end
    memoize :params

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
