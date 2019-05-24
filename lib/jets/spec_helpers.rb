# frozen_string_literal: true

require 'base64'

module Jets
  module SpecHelpers
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

      request.params.query_params = params.delete(:query)
      request.params.query_params ||= params if request.method == :get
      request.params.query_params ||= {}

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

require "rspec"
RSpec.configure do |c|
  c.include Jets::SpecHelpers
end