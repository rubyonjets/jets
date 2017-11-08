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
        render_json(options)
      elsif options.has_key?(:text)
        options[:text]
      elsif options.has_key?(:template)
        render_template(options)
      else
        raise "Unsupported render option. Only :text and :json supported.  options #{options.inspect}"
      end
    end

    # render json: {my: data}, status: 200
    def render_json(options={})
      body = options.delete(:json)
      # to_attrs allows us to use:
      #   render json: {post: post}
      body = body.respond_to?(:to_attrs) ? body.to_attrs : body
      body = JSON.dump(body) # body must be a String
      options[:body] = body # important to set as it was originally options[:json]

      render_aws_proxy(options)
    end

    def render_template(options={})
      # only require action_controller when necessary
      require 'action_controller'
      ActionController::Base.append_view_path("app/views")
      renderer = ActionController::Base.renderer
      body = renderer.render(template: template_name)
      options[:body] = body # important to set as it was originally nil

      render_aws_proxy(options)
    end

    # Transform the structure to AWS_PROXY compatiable structure
    # AWS Docs Output Format of a Lambda Function for Proxy Integration
    # http://docs.aws.amazon.com/apigateway/latest/developerguide/set-up-lambda-proxy-integrations.html#api-gateway-simple-proxy-for-lambda-output-format
    #
    # {statusCode: ..., body: ..., headers: ..., isBase64Encoded: ... }
    def render_aws_proxy(options={})
      # we do some normalization here
      status = options[:status] || 200
      headers = options[:headers] || {}
      headers = cors_headers.merge(headers)
      body = options[:body]
      base64 = options[:base64] if options.has_key?(:base64)
      base64 = options[:isBase64Encoded] if options.has_key?(:isBase64Encoded)

      if body.is_a?(Hash)
        headers["Content-Type"] = "application/json"
      else
        headers["Content-Type"] = "text/html; charset=utf-8"
      end

      # Compatiable Lambda Proxy Hash
      # Explictly assign keys, additional keys will not be compatiable
      resp = {
        statusCode: status,
        headers: headers,
        body: body,
        isBase64Encoded: base64,
      }
    end

    # Example: posts/index
    def template_name
      class_name = self.class.name.to_s.sub('Controller','').underscore
      action_name = @options[:meth] # All the way from the MainProcessor
      "#{class_name}/#{action_name}"
    end

    def cors_headers
      return {} unless Jets.config.cors
      {
        "Access-Control-Allow-Origin" => "*", # Required for CORS support to work
        "Access-Control-Allow-Credentials" => "true" # Required for cookies, authorization headers with HTTPS
      }
    end

  end
end
