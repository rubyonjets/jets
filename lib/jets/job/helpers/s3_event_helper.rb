module Jets::Job::Helpers
  module S3EventHelper
    def s3_event_payloads
      messages = event["Records"].map do |record|
        record["Sns"]["Message"]
      end
      messages.map do |message|
        h = JSON.load(message)
        ActiveSupport::HashWithIndifferentAccess.new(h)
      end
    end

    def s3_event_payloads?
      event["Records"]&.any? { |r| r.dig("Sns", "Message") }
    end

    def s3_objects
      s3_event_payloads.map do |payload|
        records = payload["Records"]
        records.map do |record|
          record["s3"]["object"]
        end
      end.flatten
    end

    def s3_objects?
      s3_event_payloads["Records"]&.any? { |r| r.dig("s3", "object") }
    end

    # Deprecated methods below
    def s3_event
      puts "WARN: s3_event is deprecated".color(:yellow)
      puts "It can possibly drop events when come in extremely fast."
      puts "Use s3_event_payloads instead"
      s3_event_payloads.first
    end

    def s3_object
      puts "WARN: s3_object is deprecated".color(:yellow)
      puts "It can possibly drop events when come in extremely fast."
      puts "Use s3_objects instead"
      s3_objects.first
    end
  end
end
