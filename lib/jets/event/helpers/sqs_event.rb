module Jets::Event::Helpers
  module SqsEvent
    extend Memoist

    def sqs_records
      event[:Records].map { |record| record }
    end
    memoize :sqs_records

    def sqs_events
      records = sqs_records
      return [] unless records
      records.map do |record|
        JSON.parse(record[:body])
      end
    end
    memoize :sqs_events

    def sqs_events?
      sqs_records&.any? { |r| r.dig(:body) }
    end
  end
end
