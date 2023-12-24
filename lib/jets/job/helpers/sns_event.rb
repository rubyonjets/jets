module Jets::Job::Helpers
  module SnsEvent
    def sns_events
      records = event["Records"]
      return [] unless records
      records.map do |record|
        message = record["Sns"]["Message"]
        ActiveSupport::HashWithIndifferentAccess.new(JSON.load(message))
      end
    end
    alias sns_event_payloads sns_events

    def sns_events?
      event["Records"]&.any? { |r| r.dig("Sns", "Message") }
    end
    alias sns_event_payloads? sns_events?

    # Deprecated methods below
    def sns_event_payload
      puts "WARN: sns_event_payload is deprecated".color(:yellow)
      puts "It can possibly drop events when they come in extremely fast."
      puts "Use sns_events instead"
      sns_events.first
    end
  end
end