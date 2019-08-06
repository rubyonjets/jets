module Jets
  module SpecHelpers
    class Response
      attr_reader :status, :headers, :body
      def initialize(response)
        @status = response['statusCode'].to_i
        @headers = response['headers']
        @body = response['body']
      end
    end
  end
end
