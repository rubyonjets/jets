# frozen_string_literal: true

class Alert < Jets::Stack
  sns_topic "delivered"
end
