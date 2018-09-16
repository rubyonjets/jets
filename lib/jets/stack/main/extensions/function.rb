module Jets::Stack::Main::Dsl
  module Function
    # Example:
    #
    #   function(:hello,
    #     handler: handler("hello.lambda_hander"),
    #     runtime: "python3.6"
    #   )
    def function(id, props={})
      # Required: code, handler, role, runtime Docs: https://amzn.to/2pdot7S
      defaults = {
        function_name: "#{Jets.config.project_namespace}-#{id.to_s.underscore}",
        code: {
          s3_bucket: "!Ref S3Bucket",
          s3_key: code_s3_key
        },
        role: "!Ref IamRole",
      }
      props = defaults.merge(props)
      props[:runtime] = "node8.10" if props[:runtime].to_s == "ruby"

      resource(id, "AWS::Lambda::Function", props)
      output(id)
    end

    def ruby_function(id, props={})
      meth = id.to_s.underscore
      props[:handler] ||= handler("#{meth}.handle") # default convention
      props[:runtime] = :ruby
      function(id, props)
    end

    def python_function(id, props={})
      meth = id.to_s.underscore
      props[:handler] ||= handler("#{meth}.lambda_handler") # default convention
      props[:runtime] = "python3.6"
      function(id, props)
    end

    def node_function(id, props={})
      meth = id.to_s.underscore
      props[:handler] ||= handler("#{meth}.handler") # default convention
      props[:runtime] = "node8.10"
      function(id, props)
    end
  end
end