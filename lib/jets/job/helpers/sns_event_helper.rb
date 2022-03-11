module Jets::Job::Helpers
    module SnsEventHelper
       def sns_event_payload
          message = event&.dig("Records", 0, "Sns", "Message")
          @sns_event_payload ||= ActiveSupport::HashWithIndifferentAccess.new(JSON.load(message))
      end
    end
end