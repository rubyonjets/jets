# Somewhat based off of: https://github.com/rails/rails/blob/master/actionpack/lib/action_dispatch/http/request.rb
class Jets::Controller
  class Request
    def initialize(event)
      @event = event
    end

    # lambda integration proxy headers
    HEADER_METHODS = %w[
      Accept
      Accept-Encoding
      Accept-Language
      cache-control
      CloudFront-Forwarded-Proto
      CloudFront-Is-Desktop-Viewer
      CloudFront-Is-Mobile-Viewer
      CloudFront-Is-SmartTV-Viewer
      CloudFront-Is-Tablet-Viewer
      CloudFront-Viewer-Country
      content-type
      Host
      origin
      Referer
      upgrade-insecure-requests
      User-Agent
      Via
      X-Amz-Cf-Id
      X-Amzn-Trace-Id
      X-Forwarded-For
      X-Forwarded-Port
      X-Forwarded-Proto
    ].freeze

    HEADER_METHODS.each do |meth|
      class_eval <<-METHOD, __FILE__, __LINE__ + 1
        def #{meth.downcase.underscore}       # def content_type
          headers["#{meth.downcase}"].freeze  #   headers["content-type"]
        end                                   # end
      METHOD
    end

    # API Gateway is inconsistent about how it cases it keys.
    # Sometimes it is "x-requested-with" vs "X-Requested-With"
    # Normalize it with downcase.
    def headers
      headers = @event["headers"] || {}
      headers.transform_keys { |key| key.downcase }
    end

    def xhr?
      headers["x-requested-with"] == "XMLHttpRequest"
    end

  end
end
