module Jets::SpecHelpers
  module Controllers
    include Jets::Router::Helpers # must be at the top because response is overridden later

    rest_methods = %w[get post put patch delete]
    rest_methods.each do |meth|
      define_method(meth) do |path, **params|
        http_call(method: meth, path: path, **params)
      end
      # Example:
      # def get(path, **params)
      #   http_call(method: :get, path: path, **params)
      # end
    end

    attr_reader :request, :response
    def http_call(method:, path:, **options)
      headers = options.delete(:headers) || {}
      md = path.match(/\?(.*)/)
      query_string = md ? md[1] : ''
      query = Rack::Utils.parse_nested_query(query_string)

      params = Params.new
      if method.to_sym == :get
        params.body_params = {}
        params.query_params ||= options.delete(:params) || options
      else
        params.body_params = options.delete(:body) || options.delete(:params) || options
      end
      params.path_params = params.path_params
      params.query_params = query

      # Note: Do not cache the request object.  Otherwise, it cannot be reused between specs.
      # See: https://community.rubyonjets.com/t/is-jets-spechelpers-controllers-request-being-cached/244/2
      @request = Request.new(method, path, headers, params)

      @request.method = method.to_sym
      @request.path = path
      @request.headers.deep_merge!(headers)

      suppress_logging do
        @response = @request.dispatch!
      end
    end

    def suppress_logging
      old_logger = Jets.logger
      unless ENV['JETS_TEST_LOGGING']
        Jets.logger = ActionView::Base.logger = Logger.new("/dev/null")
      end
      yield
      Jets.logger = old_logger
    end
  end
end
