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
        def #{meth.downcase.underscore}     # def content_type
          headers["#{meth}"].freeze  #   headers["content-type"]
        end                                 # end
      METHOD
    end

    def headers
      @event["headers"] || {}
    end

    def xhr?
      headers["X-Requested-With"] == "XMLHttpRequest"
    end

  end
end
