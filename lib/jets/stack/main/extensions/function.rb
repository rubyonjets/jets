module Jets::Stack::Main::Dsl
  module Function
    # Example:
    #
    #   function(:hello,
    #     handler: handler("hello.lambda_hander"),
    #     runtime: "python3.6"
    #   )
    #
    # Defaults to ruby:
    #
    #   function(:hello)
    #
    # is the same as
    #
    #   function(:hello,
    #     handler: handler("hello.hande"),
    #     runtime: :ruby
    #   )
    #
    def function(id, props={})
      # Required: code, handler, role, runtime Docs: https://amzn.to/2pdot7S
      meth = id.to_s.underscore
      defaults = {
        function_name: "#{Jets.config.project_namespace}-#{id.to_s.underscore}",
        code: {
          s3_bucket: "!Ref S3Bucket",
          s3_key: code_s3_key
        },
        role: "!Ref IamRole",
        handler: "#{meth}.handle", # default ruby convention
        runtime: :ruby,
      }
      props = defaults.merge(props)
      props[:runtime] = "node8.10" if props[:runtime].to_s == "ruby"
      props[:handler] = handler(props[:handler])

      resource(id, "AWS::Lambda::Function", props)
    end
    alias_method :ruby_function, :function

    def python_function(id, props={})
      meth = id.to_s.underscore
      props[:handler] ||= "#{meth}.lambda_handler" # default python convention
      props[:runtime] = "python3.6"
      function(id, props)
    end

    def node_function(id, props={})
      meth = id.to_s.underscore
      props[:handler] ||= "#{meth}.handler" # default python convention
      props[:runtime] = "node8.10"
      function(id, props)
    end
  end
end