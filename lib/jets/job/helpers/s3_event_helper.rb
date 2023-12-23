module Jets::Job::Helpers
  module S3EventHelper
    def s3_events
      messages = event["Records"].map do |record|
        record["Sns"]["Message"]
      end
      message.map do |message|
        h = JSON.load(message)
        ActiveSupport::HashWithIndifferentAccess.new(h)
      end
    end

    def s3_events?
      event["Records"]&.any? { |r| r.dig("Sns", "Message") }
    end

    def s3_objects
      records = s3_event["Records"]
      records.map do |record|
        record["s3"]["object"]
      end
    end

    def s3_objects?
      s3_event["Records"]&.any? { |r| r.dig("s3", "object") }
    end

    # Deprecated methods below
    def s3_event
      puts "WARN: s3_event is deprecated".color(:yellow)
      puts "It can possibly drop events when come in extremely fast."
      puts "Use s3_events instead"
      s3_events.first
    end

    def s3_object
      puts "WARN: s3_object is deprecated".color(:yellow)
      puts "It can possibly drop events when come in extremely fast."
      puts "Use s3_objects instead"
      s3_objects.first
    end
  end
end
