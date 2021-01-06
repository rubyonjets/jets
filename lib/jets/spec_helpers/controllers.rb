module Jets::SpecHelpers
  module Controllers
    include Jets::Router::Helpers # must be at the top because response is overridden later

    attr_reader :response
    # Note: caching it like this instead of within the initialize results in the headers not being cached
    # See: https://community.rubyonjets.com/t/is-jets-spechelpers-controllers-request-being-cached/244/2
    def request
      @request ||= Request.new(:get, '/', {}, Params.new)
    end

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

    def http_call(method:, path:, **params)
      request.method = method.to_sym
      request.path = path
      request.headers.deep_merge!(params.delete(:headers) || {})

      request.params.query_params = params.delete(:query)

      if request.method == :get
        request.params.body_params = {}
        request.params.query_params ||= params.delete(:params)
        request.params.query_params ||= params
      else
        request.params.body_params = params.delete(:params)
        request.params.body_params ||= params
      end

      request.params.query_params ||= {}

      request.params.path_params = params

      @response = request.dispatch!
    end
  end
end
