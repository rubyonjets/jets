module Jets::Job::Helpers
  module SnsEventHelper
    def sns_event_payloads
      records = event["Records"]
      return [] unless records
      records.map do |record|
        message = record["Sns"]["Message"]
        ActiveSupport::HashWithIndifferentAccess.new(JSON.load(message))
      end
    end

    def sns_event_payloads?
      event["Records"]&.any? { |r| r.dig("Sns", "Message") }
    end

    # Deprecated methods below
    def sns_event_payload
      puts "WARN: sns_event_payload is deprecated".color(:yellow)
      puts "It can possibly drop events when come in extremely fast."
      puts "Use sns_event_payloads instead"
      sns_event_payloads.first
    end
  end
end