module Jets::Resource::ChildStack
  module CommonParameters
    def common_parameters
      parameters = {
        IamRole: "!GetAtt IamRole.Arn",
        S3Bucket: "!Ref S3Bucket",
      }
      parameters[:GemLayer] = "!Ref GemLayer" unless Jets.poly_only?
      parameters
    end

    extend self
  end
end
