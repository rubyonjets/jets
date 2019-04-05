require 'base64'

module Jets::Job::Helpers
  module KinesisEventHelper
    def kinesis_data
      records = event["Records"]
      records.map do |record|
        encoded = record["kinesis"]["data"]
        Base64.decode64(encoded) # data
      end
    end
  end
end
