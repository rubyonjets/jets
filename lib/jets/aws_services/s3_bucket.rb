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
    rescue Aws::S3::Errors::BucketAlreadyExists => e
      puts "ERROR #{e.class}: #{e.message}".color(:red)
      puts "Bucket name: #{@name}"
      exit 1
    end

    def exists?
      begin
        s3.head_bucket(bucket: @name)
        true
      rescue Aws::S3::Errors::BucketAlreadyOwnedByYou, Aws::S3::Errors::Http301Error => e
        # These exceptions indicate bucket already exists
        # Aws::S3::Errors::Http301Error could be inaccurate but compromising for simplicity
        true
      rescue
        false
      end
    end
  end
end
