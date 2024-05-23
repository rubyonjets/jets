class Jets::CLI::Maintenance::Worker
  class Base < Jets::CLI::Base
    include Jets::CLI::Lambda::Functions

    attr_reader :s3_bucket
    def initialize(options = {})
      super
      @s3_bucket = Jets.aws.s3_bucket
    end

    def state_file
      "jets/state/maintenance/lambda_concurrency_settings.json"
    end

    def lambda_functions
      super.select do |lambda_function|
        # Accounts for both app/events and app/jobs (from jets geneneration)
        lambda_function.name.match(/_event-/)
      end
    end
  end
end
