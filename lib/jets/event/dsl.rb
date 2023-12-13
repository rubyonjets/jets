require "active_support"
require "active_support/core_ext/class"

# Jets::Event::Base < Jets::Lambda::Functions
# Both Jets::Event::Base and Jets::Lambda::Functions have Dsl modules included.
# So the Jets::Event::Dsl overrides some of the Jets::Lambda::Functions behavior.
#
# Implements:
#
#   default_associated_resource_definition
#
module Jets::Event::Dsl
  extend ActiveSupport::Concern

  included do
    class << self
      include Jets::AwsServices

      include DynamodbEvent
      include IotEvent
      include KinesisEvent
      include LogEvent
      include S3Event
      include ScheduledEvent
      include SnsEvent
      include SqsEvent

      # TODO: Get rid of default_associated_resource_definition concept.
      # Also gets rid of the need to keep track of running @associated_properties too.
      def default_associated_resource_definition(meth)
        events_rule_definition
      end
    end
  end
end
