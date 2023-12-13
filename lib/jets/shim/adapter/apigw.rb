module Jets::Shim::Adapter
  class Apigw < Web
    # See: https://github.com/rack/rack/blob/main/lib/rack/constants.rb
    def env
      {
        # Request env keys
        "HTTP_HOST" => host,
        "HTTP_PORT" => headers["X-Forwarded-Port"],
        "HTTPS" => https,
        "PATH_INFO" => path_info,
        "QUERY_STRING" => query_string,
        "REQUEST_METHOD" => event["httpMethod"] || "GET", # useful to default to GET when testing with Lambda console
        "REQUEST_PATH" => path_info,
        "SCRIPT_NAME" => "",
        "SERVER_NAME" => host,
        "SERVER_PORT" => headers["X-Forwarded-Port"],
        "SERVER_PROTOCOL" => event.dig("requestContext", "protocol") || "HTTP/1.1"
      }
    end

    def path_info
      event["path"] || "/" # always set by API Gateway, but setting to make shim testing easier
    end

    def handle?
      host =~ /execute-api/ ||
        event["resource"] && event.dig("requestContext", "stage")
    end

    private

    def query_string
      query = event["queryStringParameters"] || {} # always set with API Gateway but when testing shim might not be
      Rack::Utils.build_nested_query(query)
    end
  end
end
