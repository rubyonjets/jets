module Jets::Cfn::Resource::S3
  class Bucket < Jets::Cfn::Base
    attr_reader :bucket_logical_id
    def initialize(props = {})
      @props = props # associated_properties from dsl.rb
      @bucket_logical_id = props.delete(:logical_id) || "{namespace}_s3_bucket"
    end

    def definition
      {
        bucket_logical_id => {
          Type: "AWS::S3::Bucket",
          Properties: @props
        }
      }
    end

    def outputs
      {
        bucket_logical_id => "!Ref #{bucket_logical_id.to_s.camelize}"
      }
    end
  end
end
