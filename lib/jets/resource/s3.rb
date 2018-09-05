class Jets::Resource
  class S3 < Jets::Resource::Base
    def definition
      {
        s3_bucket: {
          type: "AWS::S3::Bucket"
        }
      }
    end

    def outputs
      {
        "S3Bucket" => "!Ref S3Bucket",
      }
    end
  end
end