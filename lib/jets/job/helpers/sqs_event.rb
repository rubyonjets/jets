module Jets::Job::Helpers
  module SqsEvent
    def sqs_events
      records = event["Records"]
      return [] unless records
      records.map do |record|
        message = record["body"]
        ActiveSupport::HashWithIndifferentAccess.new(JSON.load(message))
      end
    end
    alias sqs_event_payloads sqs_events

    def sqs_events?
      event["Records"]&.any? { |r| r.dig("body") }
    end
    alias sqs_event_payloads? sqs_events?

    # Deprecated methods below
    def sqs_event_payload
      puts "WARN: sqs_event_payload is deprecated".color(:yellow)
      puts "It can possibly drop events when they come in extremely fast."
      puts "Use sqs_events instead"
      sqs_events.first
    end
  end
end
