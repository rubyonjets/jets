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
module Jets::Resource::Lambda
  class LayerVersion < Jets::Resource::Base
    def definition
      {
        layer_version_logical_id => {
          type: "AWS::Lambda::LayerVersion",
          properties: {
            # compatible_runtimes: ["ruby2.5"],
            content: {
              s3_bucket: s3_bucket,
              s3_key: code_s3_key,
              # s3_object_version: string,
            },
            description: description,
            layer_name: layer_name,
            license_info: "MIT",
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