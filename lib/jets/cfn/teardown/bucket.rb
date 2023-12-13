class Jets::Cfn::Teardown
  class Bucket
    include Jets::AwsServices
    include Jets::Util::Logging
    delegate :s3_bucket, to: "Jets.project"

    def empty!
      delete_objects
      wait_for_emptiness
    end

    def delete_objects(call_count = 0)
      return unless bucket_exists?

      # Must first remove all objects from s3 bucket in order to delete stack
      log.info "Emptying s3 bucket #{s3_bucket}" if s3_bucket && call_count == 0

      resp = s3.list_objects(bucket: s3_bucket)
      if resp.contents.size > 0
        # IE: objects = [{key: "objectkey1"}, {key: "objectkey2"}]
        objects = resp.contents.map { |item| {key: item.key} }
        s3.delete_objects(
          bucket: s3_bucket,
          delete: {
            objects: objects,
            quiet: false
          }
        )
        delete_objects(call_count + 1) # recursive call to keep deleting objects until bucket is empty
      end
    end

    # Think there can be a race condition since delete_objects is async
    # So we wait for the bucket to be empty
    # Before we continue with the delete stack
    def wait_for_emptiness
      return unless bucket_exists?

      @empty_bucket_checks ||= 0
      max_checks = 5
      while @empty_bucket_checks < max_checks
        is_empty = s3.list_objects(bucket: s3_bucket).contents.empty?
        if is_empty
          log.debug "Bucket '#{s3_bucket}' is empty."
          return
        else
          log.debug "Bucket '#{s3_bucket}' is not empty. Waiting..."
          sleep 2
          @empty_bucket_checks += 1
        end
      end

      log.debug "Timeout: Bucket '#{s3_bucket}' is not empty after waiting."
    end

    # Thanks: https://docs.aws.amazon.com/sdk-for-ruby/v3/developer-guide/s3-example-does-bucket-exist.html
    def bucket_exists?
      return false unless s3_bucket
      s3.head_bucket(bucket: s3_bucket, use_accelerate_endpoint: false)
      true
    rescue Aws::S3::Errors::NotFound
      false
    end

    def are_you_sure?
      if @options[:yes]
        sure = "y"
      else
        log.debug "Are you sure you want to delete the #{Jets.project.namespace.color(:green)} project? (y/N)"
        sure = $stdin.gets
      end

      unless /^y/.match?(sure)
        log.debug "Phew! Jets #{Jets.project.namespace.color(:green)} project was not deleted."
        exit 0
      end
    end
  end
end
