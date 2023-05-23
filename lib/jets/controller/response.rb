require 'action_dispatch/http/cache'
require 'action_dispatch/http/filter_redirect'
require 'monitor'
require 'rack/response'
require 'rack/utils'

module Jets::Controller
  # The response object. See Rack::Response and Rack::Response::Helpers for
  # more info:
  # http://rubydoc.info/github/rack/rack/master/Rack/Response
  # http://rubydoc.info/github/rack/rack/master/Rack/Response/Helpers
  class Response < ::Rack::Response
    include Compat::Response

    include ActionDispatch::Http::FilterRedirect
    include ActionDispatch::Http::Cache::Response
    include MonitorMixin

    attr_accessor :request

    def initialize(*)
      super
      prepare_cache_control!
    end

    # What Rack::Response#initialize does.
    def body=(body)
      if body.nil?
        @body = []
        @buffered = true
        @length = 0
      elsif body.respond_to?(:to_str)
        @body = [body]
        @buffered = true
        @length = body.to_str.bytesize
      else
        @body = body
        @buffered = false
        @length = 0
      end
      @body
    end

    # Sets the HTTP status code.
    def status=(status)
      @status = Rack::Utils.status_code(status)
    end

    def to_a
      commit!
      rack_response status, headers.to_hash
    end

    def committed?; synchronize { @committed }; end
    # sending? and send? are for compatibility but not used for Jets
    def sending?;   synchronize { @sending };   end
    def sent?;      synchronize { @sent };      end

    def commit!
      synchronize do
        before_committed
        @committed = true
      end
    end

    def before_committed
      assign_default_content_type_and_charset!
      merge_and_normalize_cache_control!(@cache_control)
      handle_conditional_get!
      handle_no_content!
    end

    def assign_default_content_type_and_charset!
      return if media_type

      ct = parsed_content_type_header
      set_content_type(ct.mime_type || Mime[:html].to_s,
                       ct.charset || self.class.default_charset)
    end

    def handle_no_content!
      if NO_CONTENT_CODES.include?(@status)
        headers.delete "Content-Length"
      end
    end

    NO_CONTENT_CODES = [100, 101, 102, 103, 204, 205, 304]
    def rack_response(status, header)
      if NO_CONTENT_CODES.include?(status)
        [status, header, []]
      else
        [status, header, body]
      end
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

    # The response code of the request.
    alias response_code status

    def media_type
      headers["Content-Type"]
    end

  private

    def calculate_content_length?
      headers["Content-Type"] and not headers["Content-Length"] and Array === body
    end

    def drop_content_info?
      status.to_i / 100 == 1 or drop_body?
    end

    DROP_BODY_RESPONSES = [204, 304]
    def drop_body?
      DROP_BODY_RESPONSES.include?(status.to_i)
    end
  end
end