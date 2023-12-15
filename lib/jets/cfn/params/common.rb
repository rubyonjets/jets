module Jets::Cfn::Params
  module Common
    def parameters
      parameters = {
        IamRole: "!GetAtt IamRole.Arn",
        S3Bucket: "!Ref S3Bucket",
      }
      parameters[:GemLayer] = "!Ref GemLayer" if Jets.gem_layer?
      parameters
    end

    extend self
  end
end
