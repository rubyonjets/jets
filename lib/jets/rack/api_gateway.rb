module Jets::Rack
  class ApiGateway
    def initialize(triplet)
      @triplet = triplet
      @status, @headers, @body = triplet
      @body = @body.first
    end

    def build
      {
        "statusCode" => @status,
        "headers" => @headers,
        "body" => @body,
        # "isBase64Encoded" => "base64",
      }
    end
  end
end