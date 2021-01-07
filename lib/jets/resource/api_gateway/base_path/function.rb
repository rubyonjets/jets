module Jets::Resource::ApiGateway::BasePath
  class Function < Jets::Resource::Base
    include Jets::Resource::Lambda::Function::Environment

    def definition
      {
        base_path_function: {
          type: "AWS::Lambda::Function",
          properties: {
            function_name: function_name,
            code: {
              s3_bucket: "!Ref S3Bucket",
              s3_key: code_s3_key,
            },
            role: "!GetAtt BasePathRole.Arn",
            handler: handler,
            runtime: Jets.ruby_runtime,
            timeout: 60,
            memory_size: 1536,
            environment: env_properties[:environment],
            layers: layers,
          }
        }
      }
    end

    def layers
      ["!Ref GemLayer"]
    end

    def function_name
      method = "jets-base-path"
      # need to add the deployment timestamp because or else function name collides between deploys
      timestamp = Jets::Resource::ApiGateway::Deployment.timestamp
      "#{Jets.config.project_namespace}-#{method}-#{timestamp}"
    end

    def handler
      "handlers/functions/jets/base_path.lambda_handler"
    end

    def code_s3_key
      checksum = Jets::Builders::Md5.checksums["stage/code"]
      "jets/code/code-#{checksum}.zip" # s3_key
    end
  end
end