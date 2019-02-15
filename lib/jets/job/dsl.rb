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
  autoload :CloudwatchEvent, "jets/job/dsl/cloudwatch_event"
  autoload :DynamodbEvent, "jets/job/dsl/dynamodb_event"
  autoload :EventSourceMapping, "jets/job/dsl/event_source_mapping" # base for sqs_event, etc
  autoload :IotEvent, "jets/job/dsl/iot_event"
  autoload :KinesisEvent, "jets/job/dsl/kinesis_event"
  autoload :LogEvent, "jets/job/dsl/log_event"
  autoload :S3Event, "jets/job/dsl/s3_event"
  autoload :SnsEvent, "jets/job/dsl/sns_event"
  autoload :SqsEvent, "jets/job/dsl/sqs_event"

  included do
    class << self
      include Jets::AwsServices

      include CloudwatchEvent
      include DynamodbEvent
      include EventSourceMapping
      include IotEvent
      include KinesisEvent
      include LogEvent
      include S3Event
      include SnsEvent
      include SqsEvent

      # Need to be in here
      ASSOCIATED_PROPERTIES = %W[
        description
        state
        schedule_expression
      ]
      define_associated_properties(ASSOCIATED_PROPERTIES)
      alias_method :desc, :description

      def default_associated_resource_definition(meth)
        events_rule_definition
      end

    end
  end
end
