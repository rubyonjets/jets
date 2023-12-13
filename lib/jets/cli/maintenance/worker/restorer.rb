class Jets::CLI::Maintenance::Worker
  class Restorer < Base
    def restore_concurrency_settings
      data = read_from_s3
      data.each do |function_name, settings|
        lambda_function = Jets::CLI::Lambda::Function.new(function_name)
        lambda_function.reserved_concurrency = settings["reserved_concurrency"] if settings["reserved_concurrency"]
        lambda_function.provisioned_concurrency = settings["provisioned_concurrency"] if settings["provisioned_concurrency"]
      end
    end

    private

    def read_from_s3
      response = s3.get_object(bucket: s3_bucket, key: state_file)
      JSON.parse(response.body.read)
    end
  end
end
