# Type: "AWS::Lambda::LayerVersion"
# Properties:
#   CompatibleRuntimes:
#     - String
#     - ...
#   Content:
#     Content
#   Description: String
#   LayerName: String
#   LicenseInfo: String
module Jets::Cfn::Resource::Lambda
  class LayerVersion < Jets::Cfn::Base
    def definition
      {
        layer_version_logical_id => {
          Type: "AWS::Lambda::LayerVersion",
          Properties: {
            Content: {
              S3Bucket: s3_bucket,
              S3Key: code_s3_key,
            },
            Description: description,
            LayerName: layer_name,
            LicenseInfo: "Nonstandard",
          }
        }
      }
    end

    def s3_bucket
      "!Ref S3Bucket"
    end

    def layer_version_logical_id
      self.class.name.split('::').last
    end

    def outputs
      {
        logical_id => "!Ref #{logical_id}",
      }
    end
  end
end