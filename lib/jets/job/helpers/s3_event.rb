module Jets::Job::Helpers
  module S3Event
    def s3_events
      encoded_messages = event["Records"].map do |record|
        record["Sns"]["Message"] # SNS message is JSON
      end
      # Decode the JSON messages
      messages = encoded_messages.map do |message|
        JSON.load(message)
      end
      # Extract the S3 event records
      messages.map do |message|
        message["Records"].map do |record|
          ActiveSupport::HashWithIndifferentAccess.new(record)
        end
      end.flatten
    end
    alias s3_event_payloads s3_events

    def s3_events?
      event["Records"]&.any? { |r| r.dig("Sns", "Message") }
    end
    alias s3_event_payloads? s3_events?

    def s3_objects
      s3_events.map do |record|
        record["s3"]["object"]
      end
    end

    def s3_objects?
      s3_events.any? { |r| r.dig("s3", "object") }
    end

    # Deprecated methods below
    def s3_event
      puts "WARN: s3_event is deprecated".color(:yellow)
      puts "It can possibly drop events when they come in extremely fast."
      puts "Use s3_events instead"
      s3_events.first
    end

    def s3_object
      puts "WARN: s3_object is deprecated".color(:yellow)
      puts "It can possibly drop events when they come in extremely fast."
      puts "Use s3_objects instead"
      s3_objects.first
    end
  end
end
