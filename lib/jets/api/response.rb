require "hashie"

module Jets::Api
  class Response
    attr_reader(
      :http_resp,
      :http_body,
      :http_headers,
      :http_status,
      :request_id
    )
    def initialize(http_resp)
      @http_resp = http_resp
      @http_body = http_resp.body
      @http_headers = http_resp.to_hash
      @http_status = http_resp.code.to_i
      @request_id = http_resp["request-id"]
    end

    def data
      data = JSON.parse(@http_resp.body, symbolize_names: true)
      Hashie::Mash.new(data)
    rescue JSON::ParserError
      raise Jets::Api::Error, http_resp
    end
  end
end
