module Jets::Stack::Main::Dsl
  module Lambda
    include Jets::Util::Camelize

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
        Code: {
          S3Bucket: "!Ref S3Bucket",
          S3Key: code_s3_key
        },
        Role: "!Ref IamRole",
        Handler: "#{id}.lambda_handler", # default ruby convention
        Timeout: Jets.config.function.timeout,
        MemorySize: Jets.config.function.memory_size,
        EphemeralStorage: Jets.config.function.ephemeral_storage,
        Description: description,
      }

      function_name = "#{Jets.project_namespace}-#{class_namespace}-#{meth}"
      function_name = function_name.size > Jets::Cfn::Resource::Lambda::Function::MAX_FUNCTION_NAME_SIZE ? nil : function_name
      defaults[:FunctionName] = function_name if function_name

      props = defaults.merge(props)
      # shared/functions do not include the GemLayer and no custom runtime support
      props[:Runtime] ||= Jets.ruby_runtime
      props[:Handler] = handler(props[:Handler])

      logical_id = id.to_s.gsub('/','_')
      resource(logical_id, "AWS::Lambda::Function", props)
    end
    alias_method :ruby_function, :function
    alias_method :lambda_function, :function

    def python_function(id, props={})
      meth = sanitize_method_name(id)
      props[:Handler] ||= "#{meth}.lambda_handler" # default python convention
      props[:Runtime] ||= default_runtimes[:python]
      function(id, props)
    end

    def default_runtimes
      Jets::Cfn::Resource::Lambda::Function.default_runtimes
    end

    def node_function(id, props={})
      meth = sanitize_method_name(id)
      props[:Handler] ||= "#{meth}.handler" # default python convention
      props[:Runtime] ||= default_runtimes[:node]
      function(id, props)
    end

    # Usage:
    #
    #   permission(:my_permission, principal: "events.amazonaws.com")
    #
    def permission(id, props={})
      defaults = { Action: "lambda:InvokeFunction" }
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