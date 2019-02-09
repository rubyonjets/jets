class Custom < Jets::Stack
  resource(:howdy,
    type: "AWS::Lambda::Function",
    properties: {
      function_name: "howdy",
      code: {
        s3_bucket: "!Ref S3Bucket",
        s3_key: code_s3_key
      },
      description: "Hello world",
      handler: handler("howdy.lambda_handler"),
      memory_size: 128,
      role: "!Ref IamRole",
      runtime: "python3.6",
      timeout: 20,
    }
  )

  function(:gru, runtime: :ruby, handler: "gru.handle")

  ruby_function(:bob)
  python_function(:kevin)
  node_function(:stuart)

  output("test")
end
