module Jets::Job::Helpers
  module SqsEventHelper
    def sqs_event_payloads
      records = event["Records"]
      return [] unless records
      records.map do |record|
        message = record["body"]
        ActiveSupport::HashWithIndifferentAccess.new(JSON.load(message))
      end
    end

    def sqs_event_payloads?
      event["Records"]&.any? { |r| r.dig("body") }
    end

    # Deprecated methods below
    def sqs_event_payload
      puts "WARN: sqs_event_payload is deprecated".color(:yellow)
      puts "It can possibly drop events when come in extremely fast."
      puts "Use sqs_event_payloads instead"
      sqs_event_payloads.first
    end
  end
end
