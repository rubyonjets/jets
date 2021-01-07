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
      meth = sanitize_method_name(id)
      class_namespace = self.to_s.underscore.gsub('/','-') # IE: Jets::Domain => jets-domain
      description = "#{self.to_s} #{meth}" # not bother adding extension
      defaults = {
        code: {
          s3_bucket: "!Ref S3Bucket",
          s3_key: code_s3_key
        },
        role: "!Ref IamRole",
        handler: "#{id}.lambda_handler", # default ruby convention
        runtime: :ruby,
        timeout: Jets.config.function.timeout,
        memory_size: Jets.config.function.memory_size,
        description: description,
      }

      function_name = "#{Jets.config.project_namespace}-#{class_namespace}-#{meth}"
      function_name = function_name.size > Jets::MAX_FUNCTION_NAME_SIZE ? nil : function_name
      defaults[:function_name] = function_name if function_name

      props = defaults.merge(props)
      props[:runtime] = Jets.ruby_runtime if props[:runtime].to_s == "ruby"
      props[:handler] = handler(props[:handler])

      logical_id = id.to_s.gsub('/','_')
      resource(logical_id, "AWS::Lambda::Function", props)
    end
    alias_method :ruby_function, :function
    alias_method :lambda_function, :function

    def python_function(id, props={})
      meth = sanitize_method_name(id)
      props[:handler] ||= "#{meth}.lambda_handler" # default python convention
      props[:runtime] = "python3.6"
      function(id, props)
    end

    def node_function(id, props={})
      meth = sanitize_method_name(id)
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

  private
    # demo-dev-hard_job-dig_me
    def sanitize_method_name(id)
      id.to_s.gsub('/','-')
    end
  end
end