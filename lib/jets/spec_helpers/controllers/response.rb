module Jets::SpecHelpers::Controllers
  class Response
    attr_reader :status, :headers, :body
    def initialize(response)
      @status = response['statusCode'].to_i
      @headers = response['headers']
      @body = response['body']
    end
  end
end
