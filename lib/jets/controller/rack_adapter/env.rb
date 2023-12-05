require 'rack'
require 'base64'

# Only called by AWS Lambda
# Takes an ApiGateway event and converts it to an Rack env that can be used for rack middleware
module Jets::Controller::RackAdapter
  class Env
    def initialize(event, context, options={})
      @event, @context, @options = event, context, options
    end

    def convert
      options = {}
      options = add_top_level(options)
      options = add_http_headers(options)
      path = path_with_base_path || @event['path'] || '/' # always set by API Gateway but might not be when testing shim, so setting it to make testing easier

      # In case of non-ascii characters, CGI.escape will escape them
      # IE: get '/ほげ'
      # This just because MockRequest.env_for uses URI.parse which does not
      # escape non-ascii characters and throws an error
      unescaped_path = path
      path = path.chars.map { |char| char.ascii_only? ? char : CGI.escape(char) }.join
      env = Rack::MockRequest.env_for(path, options)
      env['PATH_INFO'] = unescaped_path
      # env['QUERY_STRING'] = query_string
      env
    end

  private
    def path_with_base_path
      resource = @event['resource']
      pathParameters = @event['pathParameters']

      if(!pathParameters.nil? and !resource.nil?)
        resource = pathParameters.reduce(resource) {|resource, parameter|
          key, value = parameter
          resource = resource.gsub("{#{key}+}", value)
          resource = resource.gsub("{#{key}}", value)
          resource
        }
      end

      resource
    end

    def add_top_level(options)
      map = {
        'CONTENT_TYPE' => content_type,
        'QUERY_STRING' => query_string,
        'REMOTE_ADDR' => headers['X-Forwarded-For'],
        'REMOTE_HOST' => headers_host,
        'REQUEST_METHOD' => @event['httpMethod'] || 'GET', # useful to default to GET when testing with Lambda console
        'REQUEST_PATH' => @event['path'],
        'REQUEST_URI' => request_uri,
        'SCRIPT_NAME' => "",
        'SERVER_NAME' => headers_host,
        'SERVER_PORT' => headers['X-Forwarded-Port'],
        'SERVER_PROTOCOL' => "HTTP/1.1",  # unsure if this should be set
        'SERVER_SOFTWARE' => headers['User-Agent'],
      }

      map['CONTENT_LENGTH'] = content_length if content_length
      # Even if not set, Rack always assigns an StringIO to "rack.input"
      map['rack.input'] = StringIO.new(body) if body

      options.merge(map)
    end

    # Generally should use content_type method instead of headers['Content-Type'] because
    # headers['Content-Type'] is not normally available for Rails.
    #
    # Jets makes it available and normalizes the casing by grabbing it from APIGW event['headers']
    # APIGW is inconsistent about the casing.
    # In POST request it's content-type and in GET request it's Content-Type
    #
    #   Rack (local) uses Content-Type and APIGW (remote) uses content-type
    #   Rack::MethodOverride relys on content-type to detect content type properly.
    #
    def content_type
      headers['Content-Type'] || headers['content-type']
    end

    def content_length
      bytesize = body.bytesize.to_s if body
      headers['Content-Length'] || bytesize
    end

    # Decoding base64 from API Gateaway if necessary
    # Rack will be none the wiser
    def body
      if @event['isBase64Encoded']
        Base64.decode64(@event['body'])
      else
        @event['body']
      end
    end

    def add_http_headers(options)
      headers.each do |k,v|
        # content-type => HTTP_CONTENT_TYPE
        key = k.gsub('-','_').upcase
        key = "HTTP_#{key}"
        if k == "Host"
          options[key] = headers_host
        else
          options[key] = v
        end
      end
      options
    end

    def headers_host
      Jets.config.app.domain || headers['Host']
    end

    def request_uri
      # IE: "http://localhost:8888/posts/tung/edit?foo=bar"
      proto = headers['X-Forwarded-Proto']
      host = headers_host
      port = headers['X-Forwarded-Port']

      # Add port if needed
      if proto == 'https' && port != '443' or
         proto == 'http'  && port != '80'
        host = "#{host}:#{port}"
      end

      path = @event['path']
      qs = "?#{query_string}" unless query_string.empty?
      "#{proto}://#{host}#{path}#{qs}"
    end

    def query_string
      query = @event["queryStringParameters"] || @event["multiValueQueryStringParameters"] || {} # always set with API Gateway but when testing node shim might not be
      Rack::Utils.build_nested_query(query)
      # query.map { |k,v| "#{k}=#{v}" }.join('&')
    end

    # request headers
    def headers
      @event['headers'] || {}
    end
  end
end
