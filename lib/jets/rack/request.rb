module Jets::Rack
  class Request

    def initialize(event, request)
      @event = event
      @request = request # Jets::Controller#request
      # local rack server settings
      @host = 'localhost'
      @port = 9292
    end

    def send
      status, headers, body = nil, nil, nil
      Net::HTTP.start(@host, @port) do |http|
        user = @request.headers.delete('user')
        passwd = @request.headers.delete('passwd')

        get = Net::HTTP::Get.new(@request.path, @request.headers)
        get.basic_auth user, passwd  if user && passwd

        http.request(get) do |response|
          status = response.code.to_i
          headers = normalize_header_keys(response.each_header.to_h)
          begin
            body = response.body
          rescue TypeError, ArgumentError
            body = nil
          end
        end
      end
      {
        status: status,
        headers: headers,
        body: body,
      }
    end

    ###############################
    # DUPLICATED FROM lambda_aws_proxy.rb refactor this
    # TODO: wip, not using, maybe finish this
    CASING_MAP = {
      "Cache-Control" => "cache-control",
      "Content-Type" => "content-type",
      "Origin" => "origin",
      "Upgrade-Insecure-Requests" => "upgrade-insecure-requests",
    }

    def normalize_header_keys(headers)
      # normalize header keys, might want to do it the same way with CASING_MAP in lambda_aws_proxy.rb This seems too aggressive
      headers = headers.transform_keys { |key| key.split('-').map(&:capitalize).join('-') }
      # # Adjust the casing so it matches the Lambda AWS Proxy's structure
      # CASING_MAP.each do |nice_casing, bad_casing|
      #   if headers.key?(nice_casing)
      #     headers[bad_casing] = headers.delete(nice_casing)
      #   end
      # end
      headers
    end
  end
end
