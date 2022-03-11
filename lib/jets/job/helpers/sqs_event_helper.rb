module Jets::Job::Helpers
    module SqsEventHelper
       def sqs_event_payload
          message = event&.dig("Records", 0, "body")
          @sqs_event_payload ||= ActiveSupport::HashWithIndifferentAccess.new(JSON.parse(message))
       end
    end
end