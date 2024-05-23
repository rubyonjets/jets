module Jets::Event::Helpers
  module SnsEvent
    def sns_events
      records = event["Records"]
      return [] unless records
      records.map do |record|
        message = record["Sns"]["Message"]
        ActiveSupport::HashWithIndifferentAccess.new(JSON.load(message))
      end
    end

    def sns_events?
      event["Records"]&.any? { |r| r.dig("Sns", "Message") }
    end
  end
end
