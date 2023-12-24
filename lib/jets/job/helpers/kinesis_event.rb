require 'base64'

module Jets::Job::Helpers
  module KinesisEvent
    def kinesis_data
      records = event["Records"]
      records.map do |record|
        encoded = record["kinesis"]["data"]
        Base64.decode64(encoded) # data
      end
    end

    def kinesis_data?
      event["Records"]&.any? { |r| r.dig("kinesis", "data") }
    end
  end
end
