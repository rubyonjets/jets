module Jets::AwsServices
  class S3Bucket
    include Jets::AwsServices

    def self.ensure_exists(bucket_name)
      new(bucket_name).ensure_exists
    end

    def initialize(name)
      @name = name
    end

    def ensure_exists
      s3.create_bucket(bucket: @name) unless exists?
    end

    def exists?
      begin
        s3.head_bucket(bucket: @name)
        true
      rescue
        false
      end
    end
  end
end
