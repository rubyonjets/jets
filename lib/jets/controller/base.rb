require "active_support/core_ext/hash"
require 'json'

# Controller public methods get turned into Lambda functions.
class Jets::Controller
  class Base < Jets::BaseLambdaFunction
  private
    # Merge all the parameters together for convenience.  Users still have
    # access via events.
    #
    # Precedence:
    #   1. path parameters have highest precdence
    #   2. query string parameters
    #   3. body parameters
    def params
      query_string_params = event["queryStringParameters"] || {}
      path_params = event["pathParameters"] || {}
      # attempt to parse body in case it is json
      begin
        body_params = event["body"] ? JSON.parse(event["body"]) : {}
      rescue JSON::ParserError
        body_params = {}
      end

      params = body_params
                .deep_merge(query_string_params)
                .deep_merge(path_params)
      ActiveSupport::HashWithIndifferentAccess.new(params)
    end

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
      # to_p allows us to use
      # render json: {post: post}
      body = body.respond_to?(:to_attrs) ? body.to_attrs : body
      resp = options.merge(
        statusCode: status,
        body: JSON.dump(body) # change Hash to String
      )

      # Add cors headers if enabled
      # header values should always be String to rack won't work
      resp[:headers] = {
        "Content-Type" => "application/json",
        "Access-Control-Allow-Origin" => "*", # Required for CORS support to work
        "Access-Control-Allow-Credentials" => "true" # Required for cookies, authorization headers with HTTPS
      } if Jets.config.cors

      resp
    end
  end
end
