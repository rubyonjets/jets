module Jets::Stack::Main::Dsl
  module Lambda
    # Example:
    #
    #   function(:hello,
    #     handler: handler("hello.lambda_hander"),
    #     runtime: "python3.6"
    #   )
    #
    # Defaults to ruby. So:
    #
    #   function(:hello)
    #
    # is the same as:
    #
    #   function(:hello,
    #     handler: handler("hello.hande"),
    #     runtime: :ruby
    #   )
    #
    def function(id, props={})
      # Required: code, handler, role, runtime Docs: https://amzn.to/2pdot7S
      meth = id.to_s.underscore
      class_namespace = self.to_s.underscore.gsub('/','-') # IE: Jets::Domain => jets-domain
      function_name = "#{Jets.config.project_namespace}-#{class_namespace}-#{id.to_s.underscore}"
      defaults = {
        function_name: function_name,
        code: {
          s3_bucket: "!Ref S3Bucket",
          s3_key: code_s3_key
        },
        role: "!Ref IamRole",
        handler: "#{meth}.handle", # default ruby convention
        runtime: :ruby,
        timeout: Jets.config.function.timeout,
        memory_size: Jets.config.function.memory_size,
      }
      props = defaults.merge(props)
      props[:runtime] = "ruby2.5" if props[:runtime].to_s == "ruby"
      props[:handler] = handler(props[:handler])

      resource(id, "AWS::Lambda::Function", props)
    end
    alias_method :ruby_function, :function
    alias_method :lambda_function, :function

    def python_function(id, props={})
      meth = id.to_s.underscore
      props[:handler] ||= "#{meth}.lambda_handler" # default python convention
      props[:runtime] = "python3.6"
      function(id, props)
    end

    def node_function(id, props={})
      meth = id.to_s.underscore
      props[:handler] ||= "#{meth}.handler" # default python convention
      props[:runtime] = "nodejs8.10"
      function(id, props)
    end

    # Usage:
    #
    #   permission(:my_permission, principal: "events.amazonaws.com")
    #
    def permission(id, props={})
      defaults = { action: "lambda:InvokeFunction" }
      props = defaults.merge(props)
      resource(id, "AWS::Lambda::Permission", props)
    end
  end
end