require "action_dispatch/request/utils"
require "rack"

module Jets::Controller::Request::Compat
  # Provides these 3 methods to make it Rails compatible:
  #
  #   request_parameters
  #   query_parameters
  #   path_parameters
  #
  module Params
    extend Memoist

    delegate :normalize_encode_params, to: ActionDispatch::Request::Utils
    def set_binary_encoding(params)
      controller = path_parameters[:controller]
      action = path_parameters[:action]
      ActionDispatch::Request::Utils.set_binary_encoding(self, params, controller, action)
    end

    # Merge all the parameters together for convenience.
    # Users still have access via events.
    #
    # Precedence:
    #   1. path parameters have highest precdence
    #   2. query string parameters
    #   3. body parameters
    def parameters(include_path_params: true, include_body_params: true)
      params = {}
      params = params.deep_merge(request_parameters) if include_body_params
      params = params.deep_merge(unescape_recursively(query_parameters)) # always
      params = params.deep_merge(path_parameters) if include_path_params
      params = set_binary_encoding(params)
      params = normalize_encode_params(params)
      params
    end
    memoize :parameters
    alias params parameters

    def path_parameters
      path_params = event["pathParameters"] || {}
      path_params.merge!(path_parameters_defaults)
      path_params = path_params.map { |k, path| [k, CGI.unescape(path.to_s)] }.to_h
    end

    def path_parameters_defaults
      route = Jets::Router::Matcher.new.find_by_request(self)
      if route
        controller = route.controller_name.delete_suffix("Controller").underscore
        {
          controller: controller,
          action: route.action_name,
        }.merge(route.resolved_defaults)
      else
        {}
      end
    end

    # Based on ActionDispatch::Request#GET https://bit.ly/48hvDwe
    # Override Rack's GET method to support indifferent access.
    def GET
      fetch_header("action_dispatch.request.query_parameters") do |k|
        params = event["queryStringParameters"] || {}
        set_binary_encoding(params)
        set_header k, normalize_encode_params(params)
      end
    end
    alias query_parameters GET

    # Based on ActionDispatch::Request#POST https://bit.ly/48fxh1A
    # Override Rack's POST method to support indifferent access.
    def POST
      fetch_header("action_dispatch.request.request_parameters") do
        params = get_request_parameters
        self.request_parameters = normalize_encode_params(params)
      end
    end
    alias request_parameters POST

    def request_parameters=(params)
      raise if params.nil?
      set_header("action_dispatch.request.request_parameters", params)
    end

    def get_request_parameters
      body = event['isBase64Encoded'] ? base64_decode(event["body"]) : event["body"]
      return {} if body.nil?

      parsed_json = parse_json(body)
      return parsed_json if parsed_json

      if content_type.to_s.include?("application/x-www-form-urlencoded")
        return ::Rack::Utils.parse_nested_query(body)
      elsif content_type.to_s.include?("multipart/form-data")
        return parse_multipart(body)
      end

      {} # fallback to empty Hash
    end
    memoize :get_request_parameters

    # jets specific
    def request_method_from_hidden_method_field
      get_request_parameters["_method"].to_s.upcase if get_request_parameters["_method"]
    end

  private

    def parse_multipart(body)
      boundary = ::Rack::Multipart::Parser.parse_boundary(content_type)
      options = multipart_options(body, boundary)
      env = ::Rack::MockRequest.env_for("/", options)
      ::Rack::Multipart.parse_multipart(env) # params Hash
    end

    def multipart_options(data, boundary = "AaB03x")
      type = %(multipart/form-data; boundary=#{boundary})
      length = data.bytesize

      { "CONTENT_TYPE" => type,
        "CONTENT_LENGTH" => length.to_s,
        :input => StringIO.new(data) }
    end

    def parse_json(text)
      JSON.parse(text)
    rescue JSON::ParserError
      nil
    end

    def base64_decode(body)
      return nil if body.nil?
      Base64.decode64(body)
    end

    def unescape_recursively(obj)
      case obj
      when Hash then obj.map { |k, v| [k, unescape_recursively(v)] }.to_h
      when Array then obj.map { |v| unescape_recursively(v) }
      else CGI.unescape(obj.to_s)
      end
    end
  end
end
