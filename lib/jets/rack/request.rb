module Jets::Rack
  class Request

    def initialize(event, controller)
      @event = event
      @controller = controller # Jets::Controller instance
      # local rack server settings
      @host = 'localhost'
      @port = 9292
    end

    def send
      request = @controller.request

      uri = URI("http://#{@host}:#{@port}#{request.path}")
      params = @controller.params(raw: true, path_parameters: false)
      uri.query = URI.encode_www_form(params)

      result = Net::HTTP.get_response(uri)
      puts result.body
      {
        status: result.code.to_i,
        headers: result.each_header.to_h,
        body: result.body,
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
