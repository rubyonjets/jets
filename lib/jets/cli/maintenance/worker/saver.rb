class Jets::CLI::Maintenance::Worker
  class Saver < Base
    def save_concurrency_settings
      concurrency_settings = Jets::CLI::Concurrency::Info.new(@options).concurrency_settings
      save_to_s3(concurrency_settings)
    end

    private

    def save_to_s3(data)
      s3.put_object(bucket: s3_bucket, key: state_file, body: data.to_json)
      log.debug "Saved concurrency settings to s3://#{s3_bucket}/#{state_file}"
    end
  end
end
