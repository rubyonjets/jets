require "action_controller/metal/strong_parameters"

class Jets::Controller
  module Params
  private
    # Merge all the parameters together for convenience.  Users still have
    # access via events.
    #
    # Precedence:
    #   1. path parameters have highest precdence
    #   2. query string parameters
    #   3. body parameters
    def params
      query_string_params = event["queryStringParameters"] || {}
      path_params = event["pathParameters"] || {}
      params = body_params
                .deep_merge(query_string_params)
                .deep_merge(path_params)
      ActionController::Parameters.new(params)
    end

    def body_params
      body = event["body"]
      return {} if body.nil?

      # Try json parsing
      parsed_json = parse_json(body)
      return parsed_json if parsed_json


      # For content-type application/x-www-form-urlencoded CGI.parse the body
      if event["headers"] && event["headers"]["content-type"]
        content_type = event["headers"]["content-type"]
      end
      if content_type&.include?("application/x-www-form-urlencoded")
        return Rack::Utils.parse_nested_query(body)
      end

      # Rack::Utils.parse_nested_query
      # attempt to parse body in case it is json
      {} # fallback to empty Hash
    end

    def parse_json(text)
      JSON.parse(text)
    rescue JSON::ParserError
      nil
    end
  end
end
