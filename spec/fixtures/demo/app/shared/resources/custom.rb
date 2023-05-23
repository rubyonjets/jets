class Custom < Jets::Stack
  resource(:howdy,
    FunctionName: "howdy",
    Code: {
      S3Bucket: "!Ref S3Bucket",
      S3Key: code_s3_key
    },
    Description: "Hello world",
    Handler: handler("howdy.lambda_handler"),
    MemorySize: 128,
    Role: "!Ref IamRole",
    Runtime: "python3.6",
    Timeout: 20,
  )

  function(:gru, runtime: :ruby, handler: "gru.handle")

  ruby_function(:bob)
  python_function(:kevin)
  node_function(:stuart)

  output("test")
end
