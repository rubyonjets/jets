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
