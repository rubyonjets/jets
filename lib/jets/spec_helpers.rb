# frozen_string_literal: true

require 'base64'

module Jets
  module SpecHelpers
    autoload :Params, 'jets/spec_helpers/params'
    autoload :Request, 'jets/spec_helpers/request'
    autoload :Response, 'jets/spec_helpers/response'

    attr_reader :request, :response
    def initialize(*)
      super
      @request = Request.new(:get, '/', {}, Params.new)
      @response = nil # will be set after http_call
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

      request.params.body_params = params.delete(:params) || params || {}
      request.params.path_params = params

      @response = request.dispatch!
    end

    def fixture_path(filename)
      "#{Jets.root}/spec/fixtures/#{filename}"
    end

    def fixture_file(filename)
      File.new(fixture_path(filename))
    end
  end
end

RSpec.configure do |c|
  c.include Jets::SpecHelpers
end