require "active_support/core_ext/hash"
require 'json'
require 'rack/utils' # Rack::Utils.parse_nested_query

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
      params = body_params
                .deep_merge(query_string_params)
                .deep_merge(path_params)
      ActiveSupport::HashWithIndifferentAccess.new(params)
    end

    def body_params
      body = event["body"]
      return {} if body.nil?

      # Try json parsing
      parsed_json = parse_json(body)
      return parsed_json if parsed_json


      # For content-type application/x-www-form-urlencoded CGI.parse the body
      if event["headers"] && event["headers"]["content-type"]
        content_type = event["headers"]["content-type"]
      end
      if content_type == "application/x-www-form-urlencoded"
        return Rack::Utils.parse_nested_query(body)
      end

      # Rack::Utils.parse_nested_query
      # attempt to parse body in case it is json
      {} # fallback to empty Hash
    end

    def parse_json(text)
      JSON.parse(text)
    rescue JSON::ParserError
      nil
    end

    def render(options={})
      raise "DoubleRenderError" if @rendered

      # render json: {"mytestdata": "value1"}, status: 200, headers: {...}
      @rendered_data = if options.is_a?(Symbol) # render :new
          action_name = options
          options = {template: "#{template_namespace}/#{action_name}"}
          render_template(options)
        elsif options.has_key?(:json)
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
      require "action_controller"
      require "jets/rails_overrides"
      ActionController::Base.append_view_path("app/views")
      ActionController::Base.append_view_path("app/views/posts")

      renderer = ActionController::Base.renderer.new(
        http_host: event["headers"]["Host"],
        # https: false,
        method: event["httpMethod"].downcase,
        # script_name: "",
        # input: ""
      )
      # default options: https://github.com/rails/rails/blob/master/actionpack/lib/action_controller/renderer.rb#L41-L47
      template = options[:template] || default_template_name

      body = renderer.render(template: template, assigns: all_instance_variables, controller_name: "articles2")
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
      base64 = normalized_base64_option(options)

      if body.is_a?(Hash)
        body = JSON.dump(body) # body must be a String
        headers["Content-Type"] = "application/json"
      else
        headers["Content-Type"] = "text/html; charset=utf-8"
      end

      # Compatiable Lambda Proxy Hash
      # Explictly assign keys, additional keys will not be compatiable
      resp = {
        "statusCode" => status,
        "headers" => headers,
        "body" => body,
        "isBase64Encoded" => base64,
      }
    end

    def normalized_base64_option(options)
      base64 = options[:base64] if options.has_key?(:base64)
      base64 = options[:isBase64Encoded] if options.has_key?(:isBase64Encoded)
      base64
    end

    # redirect_to "/posts", :status => 301
    # redirect_to :action=>'atom', :status => 302
    def redirect_to(url, options={})
      unless url.is_a?(String)
        raise "redirect_to url parameter must be a String. Please pass in a string"
      end

      uri = URI.parse(url)
      # if no location.host, we been provided a relative host
      if !uri.host && event["headers"] && event["headers"]["origin"]
        url = "/#{url}" unless url.starts_with?('/')
        redirect_url = event["headers"]["origin"] + url
      else
        redirect_url = url
      end

      base64 = normalized_base64_option(options)

      resp = render_aws_proxy(
        status: options[:status] || 302,
        headers: {
          "Location" => redirect_url
        },
        body: "",
        isBase64Encoded: base64,
      )
      # so ensure_render doesnt get called and wipe out the redirect_to resp
      @rendered = true
      @rendered_data = resp
    end

    def all_instance_variables
      instance_variables.inject({}) do |vars, v|
        k = v.to_s.sub(/^@/,'') # @event => event
        vars[k] = instance_variable_get(v)
        vars
      end
    end

    # Example: posts/index
    def default_template_name
      action_name = @meth # All the way from the MainProcessor
      "#{template_namespace}/#{action_name}"
    end

    # PostsController => "posts" is the namespace
    def template_namespace
      self.class.name.to_s.sub('Controller','').underscore.pluralize
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
