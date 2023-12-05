module Jets::Cfn::Resource::ApiGateway::BasePath
  class Function < Jets::Cfn::Base
    include Jets::Cfn::Resource::Lambda::Function::Environment

    def definition
      {
        BasePathFunction: {
          Type: "AWS::Lambda::Function",
          Properties: {
            FunctionName: function_name,
            Description: "Jets#base_path",
            Code: {
              S3Bucket: "!Ref S3Bucket",
              S3Key: code_s3_key,
            },
            Role: "!GetAtt BasePathRole.Arn",
            Handler: handler,
            Runtime: get_runtime,
            Timeout: 60,
            MemorySize: 1536,
            Environment: env_properties[:Environment],
            Layers: layers,
          }
        }
      }
    end

    def get_runtime
      props = camelize(Jets.application.config.function.to_h)
      props[:Runtime] || Jets.ruby_runtime
    end

    def layers
      return Jets.config.lambda.layers if Jets.config.pro.disable
      ["!Ref GemLayer"] + Jets.config.lambda.layers
    end

    # JETS_RESET is respected here because CloudFormation Custom Resources
    # do not allow updates to the ServiceToken property.
    # Changing the base-path Lambda Function name results in a CloudFormation error:
    #
    #     Modifying service token is not allowed
    #
    def function_name
      "#{Jets.project_namespace}-jets-base-path"
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