module Jets::Shim::Adapter
  class Lambda < Web
    def env
      {
        # Request env keys
        "HTTP_HOST" => host,
        "HTTP_PORT" => headers["x-forwarded-port"],
        "HTTPS" => https,
        "PATH_INFO" => path_info,
        "QUERY_STRING" => query_string,
        "REQUEST_METHOD" => event.dig("requestContext", "http", "method") || "GET", # useful to default to GET when testing with Lambda console
        "REQUEST_PATH" => path_info,
        "SCRIPT_NAME" => "",
        "SERVER_NAME" => host,
        "SERVER_PORT" => headers["x-forwarded-proto"],
        "SERVER_PROTOCOL" => event.dig("requestContext", "http", "protocol") || "HTTP/1.1"
      }
    end

    def handle?
      host =~ /lambda-url/ ||
        event["version"] && event["routeKey"]
    end

    private

    def path_info
      event["rawPath"] || "/"
    end

    def query_string
      event["rawQueryString"] || ""
    end
  end
end
