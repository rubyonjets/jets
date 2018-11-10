require 'rack/response'

class Jets::Controller
  # The response object. See Rack::Response and Rack::Response::Helpers for
  # more info:
  # http://rubydoc.info/github/rack/rack/master/Rack/Response
  # http://rubydoc.info/github/rack/rack/master/Rack/Response/Helpers
  class Response < ::Rack::Response
    DROP_BODY_RESPONSES = [204, 304]
    def initialize(*)
      super
      # headers['Content-Type'] ||= 'text/html'
    end

    # TODO: unsure if we should even have these methods.  We dont really use them.
    def body=(value)
      value = value.body while Rack::Response === value
      @body = String === value ? [value.to_str] : value
    end

    def each
      block_given? ? super : enum_for(:each)
    end

    def finish
      result = body

      if drop_content_info?
        headers.delete "Content-Length"
        headers.delete "Content-Type"
      end

      if drop_body?
        close
        result = []
      end

      if calculate_content_length?
        # if some other code has already set Content-Length, don't muck with it
        # currently, this would be the static file-handler
        headers["Content-Length"] = body.inject(0) { |l, p| l + p.bytesize }.to_s
      end

      [status.to_i, headers, result]
    end

    private

    def calculate_content_length?
      headers["Content-Type"] and not headers["Content-Length"] and Array === body
    end

    def drop_content_info?
      status.to_i / 100 == 1 or drop_body?
    end

    def drop_body?
      DROP_BODY_RESPONSES.include?(status.to_i)
    end
  end
end