module Lam
  class BaseController
    def initialize(event, context)
      @event, @context = event, context
    end

  private
    def render(options={})
      # render json: {"mytestdata": "value1"}, status: 200, headers: {...}
      if options.has_key?(:json)
        # Transform the structure to Lambda Proxy structure
        # {statusCode: ..., body: ..., headers: }
        status = options.delete(:status)
        body = options.delete(:json)
        result = options.merge(
          statusCode: status,
          body: body
        )
      # render text: "text"
      elsif options.has_key?(:text)
        result = options.delete(:text)
      else
        raise "Unsupported render option. Only :text and :json supported.  options #{options.inspect}"
      end

      result
    end

    # API Gateway LAMBDA_PROXY wraps the event in its own structure.
    # We unwrap the "body" before sending it back
    # For regular Lambda function calls, no need to unwrap but need to
    # transform it to a string with JSON.dump.
    def normalize_event_body(event)
      body = event.has_key?("body") ? event["body"] : JSON.dump(event)
    end
  end
end