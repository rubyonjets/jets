module Jets::SpecHelpers::Controllers
  class Request
    extend Memoist

    attr_accessor :method, :path, :headers, :params
    def initialize(method, path, headers={}, params={})
      @method, @path, @headers, @params = method, path, headers, params
    end

    def event
      json = {}
      id_params = route.path.scan(%r{:([^/]+)}).flatten
      expanded_path = escape_path(path)
      path_parameters = {}

      id_params.each do |id_param|
        raise "missing param: :#{id_param}" unless path_params.include? id_param.to_sym

        path_param_value = path_params[id_param.to_sym]
        raise "Path param :#{id_param} value cannot be blank" if path_param_value.blank?

        escaped_path_param_value = CGI.escape(path_param_value.to_s)
        expanded_path.gsub!(":#{id_param}", escaped_path_param_value)
        path_parameters.deep_merge!(id_param => escaped_path_param_value)
      end

      json['resource'] = escape_path(path)
      json['path'] = expanded_path
      json['httpMethod'] = method.to_s.upcase
      json['pathParameters'] = path_parameters
      json['headers'] = (headers || {}).stringify_keys

      if method != :get
        json['headers']['Content-Type'] = 'application/x-www-form-urlencoded'
        body = Rack::Multipart.build_multipart(params.body_params)

        if body
          json['headers']['Content-Length'] ||= body.length.to_s
          json['headers']['Content-Type'] = "multipart/form-data; boundary=#{Rack::Multipart::MULTIPART_BOUNDARY}"
        else
          body = Rack::Utils.build_nested_query(params.body_params)
        end

        json['body'] = Base64.encode64(body)
        json['isBase64Encoded'] = true
      end

      params.query_params.each do |key, value|
        json['queryStringParameters'] ||= {}
        json['queryStringParameters'][key.to_s] = value.deep_dup
      end

      json
    end

    def path_params
      params.path_params.reverse_merge(extract_parameters)
    end
    memoize :path_params

    def extract_parameters
      route.extract_parameters(normalized_path).symbolize_keys
    end

    def normalized_path
      path = self.path
      path = path[0..-2] if path.end_with? '/'
      path = path[1..-1] if path.start_with? '/'
      path
    end

    def route
      Jets::Router::Finder.new(normalized_path, method).run
    end
    memoize :route

    def dispatch!
      klass = Object.const_get(route.controller_name)
      controller = klass.new(event, {}, route.action_name)
      response = controller.process! # response is API Gateway Hash

      unless response['statusCode'] && response['body']
        raise "Expected response to an API Gateway Hash Structure. Are you rendering correctly?"
      end

      Response.new(response) # converts APIGW hash to prettier object
    end

    private

    def escape_path(path)
      path.to_s.split('/').map { |s| s =~ /\A[:\*]/ ? s : CGI.escape(s) }.join('/')
    end
  end
end
