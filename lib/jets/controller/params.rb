require "action_controller/metal/strong_parameters"

class Jets::Controller
  module Params
    # Merge all the parameters together for convenience.  Users still have
    # access via events.
    #
    # Precedence:
    #   1. path parameters have highest precdence
    #   2. query string parameters
    #   3. body parameters
    def params(raw=false)
      query_string_params = event["queryStringParameters"] || {}
      path_params = event["pathParameters"] || {}
      params = body_params
                .deep_merge(query_string_params)
                .deep_merge(path_params)
      if raw
        params
      else
        ActionController::Parameters.new(params)
      end
    end

  private
    def body_params
      body = event["body"]
      return {} if body.nil?

      # Try json parsing
      parsed_json = parse_json(body)
      return parsed_json if parsed_json


      # For content-type application/x-www-form-urlencoded CGI.parse the body
      headers = event["headers"] || {}
      headers = headers.transform_keys { |key| key.downcase }
      # API Gateway seems to use either: content-type or Content-Type
      content_type = headers["content-type"]
      if content_type.to_s.include?("application/x-www-form-urlencoded")
        return Rack::Utils.parse_nested_query(body)
      end

      {} # fallback to empty Hash
    end

    def parse_json(text)
      JSON.parse(text)
    rescue JSON::ParserError
      nil
    end
  end
end
