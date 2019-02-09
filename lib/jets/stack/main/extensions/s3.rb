module Jets::Stack::Main::Dsl
  module S3
    def s3_bucket(id, props={})
      resource(id, "AWS::S3::Bucket", props)
      output(id) # Bucket name
    end

    def s3_bucket_configuration(id, props={})
      resource(id, "Custom::S3BucketConfiguration", props)
    end
  end
end
