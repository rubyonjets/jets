module Jets::Stack::Main::Dsl
  module Base
    def ref(value)
      "!Ref #{value.to_s.camelize}"
    end

    # Examples:
    #   get_attr("logical_id.attribute")
    #   get_attr("logical_id", "attribute")
    #   get_attr(["logical_id", "attribute"])
    def get_att(*item)
      item = item.flatten
      options = item.last.is_a?(Hash) ? item.pop : {}

      # list is an Array
      list = if item.size == 1
                item.first.split('.')
              else
                item
              end
      list.map! { |s| s.to_s.camelize } unless options[:autoformat] == false
      { "Fn::GetAtt" => list }
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

    # Due to `if Jets::Stack.has_resources?` check early on in the bootstraping process
    # The code has not been built at that point. So we use a placeholder and will replace
    # the placeholder as part of the cfn template build process after the code has been built
    # and the code_s3_key with md5 is available.
    def code_s3_key
      "code_s3_key_placeholder"
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
      "handlers/shared/functions/#{name}" # generated handler
    end
  end
end