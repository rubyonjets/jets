require 'active_support'
require 'active_support/core_ext/class'

# Jets::Job::Base < Jets::Lambda::Functions
# Both Jets::Job::Base and Jets::Lambda::Functions have Dsl modules included.
# So the Jets::Job::Dsl overrides some of the Jets::Lambda::Functions behavior.
#
# Implements:
#
#   default_associated_resource_definition
#
module Jets::Job::Dsl
  extend ActiveSupport::Concern
  autoload :DynamodbEvent, "jets/job/dsl/dynamodb_event"
  autoload :EventSourceMapping, "jets/job/dsl/event_source_mapping" # base for sqs_event, etc
  autoload :IotEvent, "jets/job/dsl/iot_event"
  autoload :KinesisEvent, "jets/job/dsl/kinesis_event"
  autoload :LogEvent, "jets/job/dsl/log_event"
  autoload :RuleEvent, "jets/job/dsl/rule_event"
  autoload :S3Event, "jets/job/dsl/s3_event"
  autoload :SnsEvent, "jets/job/dsl/sns_event"
  autoload :SqsEvent, "jets/job/dsl/sqs_event"

  included do
    class << self
      include Jets::AwsServices

      include DynamodbEvent
      include EventSourceMapping
      include IotEvent
      include KinesisEvent
      include LogEvent
      include RuleEvent
      include S3Event
      include SnsEvent
      include SqsEvent

      # Used to provide a little more identifiable event rule auto-descriptions
      class_attribute :rule_counter
      self.rule_counter = 0

      # TODO: Get rid of default_associated_resource_definition concept.
      # Also gets rid of the need to keep track of running @associated_properties too.
      def default_associated_resource_definition(meth)
        events_rule_definition
      end
    end
  end
end
