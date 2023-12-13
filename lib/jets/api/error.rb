module Jets::Api
  class Error < StandardError
    def initialize(message = nil, http_status: nil, http_body: nil,
      json_body: nil, http_headers: nil, code: nil)
      @message = message
      @http_status = http_status
      @http_body = http_body
      @http_headers = http_headers || {}
      @json_body = json_body
      @code = code
      @request_id = @http_headers["request-id"]
      super(message)
    end

    module Handlers
      def handle_as_error?(http_status)
        http_status >= 400
      end

      def handle_error_response!(resp)
        error = if resp.data[:error].nil?
          general_api_error("Indeterminate error", resp.http_status)
        elsif resp.data[:error].is_a?(String) # Internal Server Error
          general_api_error(resp.data[:error], resp.http_status)
        else
          specific_api_error(resp)
        end

        raise error
      end

      def general_api_error(message, http_status)
        Error.new(message, http_status: http_status)
      end

      def specific_api_error(resp)
        message = resp.data[:error][:message]
        http_status = resp.http_status

        error_class = Jets::Api::Error.http_errors[http_status]
        if error_class
          Jets::Api::Error.const_get(error_class).new(message, http_status: http_status)
        else
          general_api_error(message, http_status)
        end
      end
    end

    cattr_reader :http_errors
    @@http_errors = {
      400 => "BadRequest",
      401 => "Unauthorized",
      403 => "Forbidden",
      404 => "NotFound",
      422 => "UnprocessableEntity",
      429 => "TooManyRequests",
      500 => "InternalServerError"
    }
    # Do not correspond to http status codes
    @@other_errors = %w[
      Connection
      Maintenance
      ServiceUnavailable
    ]
    @@error_classes = @@http_errors.values + @@other_errors
    @@error_classes.each do |error_class|
      Jets::Api::Error.const_set(error_class, Class.new(Error))
    end
  end
end
