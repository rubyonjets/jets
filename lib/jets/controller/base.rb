require "active_support/core_ext/hash"
require 'json'

# Controller public methods get turned into Lambda functions.
class Jets::Controller
  class Base < Jets::BaseLambdaFunction
    def self.process(event, context, meth)
      controller = new(event, context, meth)
      controller.send(meth)
      controller.ensure_render
    end

    def ensure_render
      return @rendered_data if @rendered

      # defaults to rendering templates
      render template: default_template_name
    end

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

      puts "query_string_params #{query_string_params.inspect}"
      puts "path_params #{path_params.inspect}"
      puts "body_params #{body_params.inspect}"

      params = body_params
                .deep_merge(query_string_params)
                .deep_merge(path_params)
      ActiveSupport::HashWithIndifferentAccess.new(params)
    end

    def body_params
      body = event["body"]
      return {} if body.nil?

      # 1st try json parsing
      parsed_json = parse_json(body)
      return parsed_json if parsed_json

      # 2nd tried parsing cgi
      # if CGI.parse(body)
      # end

      {}
    end

    def parse_json(text)
      JSON.parse(text)
    rescue JSON::ParserError
      nil
    end

    def render(options={})
      raise "DoubleRenderError" if @rendered

      # render json: {"mytestdata": "value1"}, status: 200, headers: {...}
      @rendered_data = if options.has_key?(:json)
          render_json(options)
        elsif options.has_key?(:text)
          options[:text]
        elsif options.has_key?(:template)
          render_template(options)
        else
          raise "Unsupported render option. Only :text and :json supported.  options #{options.inspect}"
        end
      @rendered = true
      @rendered_data
    end

    # render json: {my: data}, status: 200
    def render_json(options={})
      body = options[:json]
      # to_attrs allows us to use:
      #   render json: {post: post}
      body = body.respond_to?(:to_attrs) ? body.to_attrs : body
      options[:body] = body # important to set as it was originally options[:json]

      render_aws_proxy(options)
    end

    def render_template(options={})
      # only require action_controller when necessary
      require 'action_controller'
      ActionController::Base.append_view_path("app/views")
      renderer = ActionController::Base.renderer
      template = options[:template] || default_template_name
      body = renderer.render(template: template, assigns: all_instance_variables)
      options[:body] = body # important to set as it was originally nil

      render_aws_proxy(options)
    end

    def all_instance_variables
      instance_variables.inject({}) do |vars, v|
        k = v.to_s.sub(/^@/,'') # @event => event
        vars[k] = instance_variable_get(v)
        vars
      end
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
        body = JSON.dump(body) # body must be a String
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
    def default_template_name
      class_name = self.class.name.to_s.sub('Controller','').underscore.pluralize
      action_name = @meth # All the way from the MainProcessor
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
