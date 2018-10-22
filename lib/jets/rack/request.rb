require 'net/http'

module Jets::Rack
  class Request
    def initialize(event, controller)
      @event = event
      @controller = controller # Jets::Controller instance
    end

    def process
      http_method = @event['httpMethod'] # GET, POST, PUT, DELETE, etc
      params = @controller.params(raw: true, path_parameters: false)

      uri = URI("http://localhost:9292#{@controller.request.path}") # local rack server
      http = Net::HTTP.new(uri.host, uri.port)

      # Rails sets _method=patch or _method=put as workaround
      # Falls back to GET when testing in lambda console
      http_class = params['_method'] || http_method || 'GET'
      http_class.capitalize!

      request_class = "Net::HTTP::#{http_class}".constantize # IE: Net::HTTP::Get
      request = request_class.new(@controller.request.path)
      if %w[Post Patch Put].include?(http_class)
        params = HashConverter.encode(params)
        request.set_form_data(params)
      end

      headers = @event['headers']
      if headers
        request['X-Forwarded-For'] = headers['X-Forwarded-For']
        request['X-Forwarded-Host'] = headers['Host']
        request['X-Forwarded-Port'] = headers['X-Forwarded-Port']
        request['X-Forwarded-Proto'] = headers['X-Forwarded-Proto']
      end

      # TODO: handle binary
      response = http.request(request)
      {
        status: response.code.to_i,
        headers: response.each_header.to_h,
        body: response.body,
      }
    end
  end
end
