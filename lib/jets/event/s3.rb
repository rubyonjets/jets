module Jets::Event
  module S3
    extend self

    # The registry tracks bucket each time an s3_event is declared
    # Map of bucket_name => stack_name (nested part)
    cattr_accessor :registry
    @@registry = {}

    def any?
      !@@registry.empty?
    end

    def create_s3_event_buckets
      buckets = @@registry.keys
      buckets.each do |bucket|
        Jets::AwsServices::S3Bucket.ensure_exists(bucket)
      end
    end
  end
end
