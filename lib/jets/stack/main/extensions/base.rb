module Jets::Stack::Main::Dsl
  module Base
    def ref(value)
      "!Ref #{value.to_s.camelize}"
    end

    def logical_id(value)
      value.to_s.camelize
    end

    def depends_on(*stacks)
      if stacks == []
        @depends_on
      else
        @depends_on ||= []
        @depends_on += stacks
      end
    end

    def code_s3_key
      Jets::Naming.code_s3_key
    end

    # resource(:hello,
    #   function_name: "hello",
    #   code: {
    #     s3_bucket: "!Ref S3Bucket",
    #     s3_key: code_s3_key
    #   },
    #   description: "Hello world",
    #   handler: handler_function("hello.lambda_handler"),
    #   memory_size: 128,
    #   role: "!Ref IamRole",
    #   runtime: "python3.6",
    #   timeout: 20,
    # )
    def handler(name)
      "handlers/shared/#{name}" # generated handler
    end
  end
end