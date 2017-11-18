class Jets::Controller
  module Rendering
    def ensure_render
      return @rendered_data if @rendered

      # defaults to rendering templates
      render template: default_template_name
    end

    # Many different ways to render:
    #
    #  render "articles/index", layout: "application"
    #  render :new
    #  render template: "articles/index", layout: "application"
    #  render json: {my: "data"}
    #  render text: "plain text"
    def render(options={}, rest={})
      raise "DoubleRenderError" if @rendered

      # render json: {"mytestdata": "value1"}, status: 200, headers: {...}
      @rendered_data = if options.is_a?(Symbol) # render :new
          action_name = options
          options = {template: "#{template_namespace}/#{action_name}"}
          render_template(options.merge(rest)) # rest might include layout
        elsif options.is_a?(String)
          options = {template: options}
          render_template(options.merge(rest)) # rest might include layout
        elsif options.has_key?(:template)
          render_template(options)
        elsif options.has_key?(:json)
          render_json(options)
        elsif options.has_key?(:file)
          render_file(options)
        elsif options.has_key?(:text)
          options[:text]
        else
          raise "Unsupported render option. Only :text and :json supported.  options #{options.inspect}"
        end
      @rendered = true
      @rendered_data
    end

    def render_file(options={})
      require "action_dispatch/http/mime_type"

      path = options[:file]
      content = IO.read(path)
      options[:body] = content

      ext = File.extname(path)[1..-1]
      mime_type = Mime::Type.lookup_by_extension(ext)
      options[:content_type] = mime_type.to_s if mime_type

      render_aws_proxy(options)
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
      setup_action_controller # setup only when necessary

      renderer = ActionController::Base.renderer.new(renderer_options)
      template = options[:template] || default_template_name
      layout = options[:layout] || self.class.layout

      body = renderer.render(
        template: template,
        layout: layout,
        assigns: all_instance_variables)
      options[:body] = body # important to set as it was originally nil

      render_aws_proxy(options)
    end

    def setup_action_controller
      require "action_controller"
      require "jets/rails_overrides"

      # laod helpers
      helper_class = self.class.name.to_s.sub("Controller", "Helper")
      helper_path = "#{Jets.root}app/helpers/#{helper_class.underscore}.rb"
      ActiveSupport.on_load :action_view do
        include ApplicationHelper
        include helper_class.constantize if File.exist?(helper_path)
      end

      ActionController::Base.append_view_path("app/views")

      setup_webpacker
    end

    def setup_webpacker
      require 'webpacker'
      require 'webpacker/helper'
      ActiveSupport.on_load :action_controller do
        ActionController::Base.helper Webpacker::Helper
      end

      ActiveSupport.on_load :action_view do
        include Webpacker::Helper
      end
    end

    # default options:
    #   https://github.com/rails/rails/blob/master/actionpack/lib/action_controller/renderer.rb#L41-L47
    def renderer_options
      # When testing lambda function directly, the event payload
      # will not not always contain event["headers"]
      return {} unless event["headers"]

      origin = event["headers"]["origin"]
      if origin
        uri = URI.parse(origin)
        https = uri.scheme == "https"
      end
      {
        http_host: event["headers"]["Host"],
        https: https,
        method: event["httpMethod"].downcase,
        # script_name: "",
        # input: ""
      }
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
        headers["Content-Type"] ||= options[:content_type] || "application/json"
      else
        headers["Content-Type"] ||= options[:content_type] || "text/html; charset=utf-8"
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
        url = add_stage_name(url)
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

    # Add API Gateway Stage Name
    def add_stage_name(url)
      if event["headers"] && event["headers"]["origin"]
        host = event["headers"]["origin"]  # with http(s) scheme
        if host.include?("amazonaws.com") && url.starts_with?('/')
          stage_name = [Jets.config.short_env, Jets.config.env_extra].compact.join('_').gsub('-','_') # Stage name only allows a-zA-Z0-9_
          url = "/#{stage_name}#{url}"
        end
      end

      url
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
