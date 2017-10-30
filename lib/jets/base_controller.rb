require 'json'

module Jets
  class BaseController < BaseModel
  private
    def render(options={})
      # render json: {"mytestdata": "value1"}, status: 200, headers: {...}
      if options.has_key?(:json)
        result = render_aws_proxy(options)
      elsif options.has_key?(:text)
        result = options.delete(:text)
      else
        raise "Unsupported render option. Only :text and :json supported.  options #{options.inspect}"
      end
      result
    end

    # render json: {my: data}, status: 200
    def render_aws_proxy(options)
      # Transform the structure to AWS_PROXY compatiable structure
      # AWS Docs Output Format of a Lambda Function for Proxy Integration
      # http://amzn.to/2gSdMan
      # {statusCode: ..., body: ..., headers: }
      status = options.delete(:status) || 200
      body = options.delete(:json)
      result = options.merge(
        statusCode: status,
        body: JSON.dump(body) # change Hash to String
      )
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