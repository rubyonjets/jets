require "rack/utils"

module Jets::CLI::Curl::Adapter
  class Lambda < Base
    def convert
      {
        version: "2.0",
        routeKey: "$default",
        rawPath: path,
        rawQueryString: raw_query_string,
        cookies: cookies,
        body: body,
        headers: headers,
        requestContext: request_context,
        isBase64Encoded: false
      }.delete_if { |k, v| v.nil? }.to_json
    end

    def cookies
      Cookies::Parser.new(@options[:cookie]).parse if @options[:cookie]
    end

    def body
      data = @options[:data]
      return unless data
      if data.starts_with?("@")
        file = data[1..]
        file = "#{Jets.root}/#{file}" unless file.starts_with?("/")
        IO.read(file) # IE: @data.json
      else
        data
      end
    end

    def headers
      default_headers.merge(headers_option)
    end

    def default_headers
      {
        host: host,
        "x-forwarded-proto": "https",
        "x-forwarded-port": "443",
        "x-forwarded-for": "127.0.0.1",
        "user-agent": "jets curl (#{Jets::VERSION})"
      }
    end

    def headers_option
      headers = @options[:headers] || {}
      headers["user-agent"] = user_agent if user_agent
      headers.transform_keys(&:downcase).transform_values(&:strip)
    end

    def host
      return default_host unless @options[:headers]
      deleted_host = @options[:headers].delete("Host")&.strip
      host = @options[:headers][:host] || deleted_host
      host || default_host
    end

    def default_host
      host = uri.host
      if host && (host.include?("amazonaws.com") || host.include?(".aws"))
        host
      else
        "#{api_id}.lambda-url.#{aws_region}.on.aws"
      end
    end

    def user_agent
      return unless @options[:headers]
      deleted_user_agent = @options[:headers].delete("User-Agent")&.strip
      @options[:headers]["user-agent"] || deleted_user_agent
    end
    memoize :user_agent # run only since .delete will change the headers_option

    def request_context
      now = Time.now.utc
      {
        accountId: "anonymous",
        apiId: api_id,
        domainName: host,
        domainPrefix: api_id,
        http: {
          method: http_method,
          path: path,
          protocol: "HTTP/1.1",
          sourceIp: "127.0.0.1",
          userAgent: user_agent
        },
        requestId: "3fca3afe-2fb7-4e93-ac3b-949519408c39",
        routeKey: "$default",
        stage: "$default",
        time: now.strftime("%d/%b/%Y:%H:%M:%S %z"),
        timeEpoch: now.to_i
      }
    end

    def api_id
      "dummy"
    end

    def aws_region
      Jets.aws.region
    end

    def http_method
      @options[:request] || "GET"
    end

    def uri
      URI.parse(@options[:path])
    end

    def path
      uri.path
    end

    def raw_query_string
      uri.query
    end

    # AWS Lambda 2.0 Behavior
    # https://docs.aws.amazon.com/apigateway/latest/developerguide/http-api-develop-integrations-lambda.html
    def parse_query_string(raw_query_string)
      query_params = {}

      raw_query_string.split("&").each do |param|
        key, value = param.split("=")
        key = key.to_sym
        if query_params.key?(key)
          query_params[key] += ",#{value}"
        else
          query_params[key] = value
        end
      end

      query_params.transform_values! { |value| value.include?(",") ? value.split(",") : value }
    end
  end
end
