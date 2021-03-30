require "action_controller/metal/strong_parameters"
require "action_dispatch"
require "rack"

class Jets::Controller
  module Params
    extend Memoist

    # Merge all the parameters together for convenience.  Users still have
    # access via events.
    #
    # Precedence:
    #   1. path parameters have highest precdence
    #   2. query string parameters
    #   3. body parameters
    def params(raw: false, path_parameters: true, body_parameters: true)
      params = {}
      params = params.deep_merge(body_params) if body_parameters
      params = params.deep_merge(unescape_recursively(query_params)) # always
      params = params.deep_merge(path_params) if path_parameters

      if raw
        params
      else
        params = ActionDispatch::Request::Utils.normalize_encode_params(params) # for file uploads
        ActionController::Parameters.new(params)
      end
    end

    def unescape_recursively(obj)
      case obj
      when Hash then obj.map { |k, v| [k, unescape_recursively(v)] }.to_h
      when Array then obj.map { |v| unescape_recursively(v) }
      else CGI.unescape(obj.to_s)
      end
    end

    def filtered_parameters(**kwargs)
      parameter_filter.filter params(**kwargs, raw: true) # Always filter raw hash
    end

    def path_params
      path_params = event["pathParameters"] || {}
      path_params = path_params.map { |k, path| [k, CGI.unescape(path)] }.to_h
    end
    alias_method :path_parameters, :path_params

    def query_params
      event["queryStringParameters"] || {}
    end
    alias_method :query_parameters, :query_params

    def request_params
      {
        controller: controller_name,
        action: action_name,
      }
    end
    alias_method :request_parameters, :request_params

    def body_params
      body = event['isBase64Encoded'] ? base64_decode(event["body"]) : event["body"]
      return {} if body.nil?

      parsed_json = parse_json(body)
      return parsed_json if parsed_json

      headers = event["headers"] || {}
      # API Gateway seems to use either: content-type or Content-Type
      headers = headers.transform_keys { |key| key.downcase }
      content_type = headers["content-type"]

      if content_type.to_s.include?("application/x-www-form-urlencoded")
        return ::Rack::Utils.parse_nested_query(body)
      elsif content_type.to_s.include?("multipart/form-data")
        return parse_multipart(body)
      end

      {} # fallback to empty Hash
    end
    memoize :body_params
    alias_method :body_parameters, :body_params

  private

    def parse_multipart(body)
      boundary = ::Rack::Multipart::Parser.parse_boundary(headers["content-type"])
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

    def parameter_filter
      @parameter_filter ||= ParametersFilter.new Jets.config.controllers.filtered_parameters
    end
  end
end
