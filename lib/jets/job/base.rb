require 'json'

# Job public methods get turned into Lambda functions.
#
# Jets::Job::Base < Jets::Lambda::Functions
# Both Jets::Job::Base and Jets::Lambda::Functions have Dsl modules included.
# So the Jets::Job::Dsl overrides some of the Jets::Lambda::Functions behavior.
class Jets::Job
  class Base < Jets::Lambda::Functions
    include Dsl

    # non-DSL methods
    include Helpers::KinesisEventHelper
    include Helpers::LogEventHelper
    include Helpers::S3EventHelper

    # Tracks bucket each time an s3_event is declared
    # Map of bucket_name => stack_name (nested part)
    cattr_accessor :s3_events # dont want this to be inheritable intentionally
    self.s3_events = {}

    class << self
      def process(event, context, meth)
        job = new(event, context, meth)
        job.send(meth)
      end

      def perform_now(meth, event={}, context={})
        new(event, context, meth).send(meth)
      end

      def perform_later(meth, event={}, context={})
        function_name = "#{self.to_s.underscore}-#{meth}"
        call = Jets::Commands::Call.new(function_name, JSON.dump(event), invocation_type: "Event")
        call.run
      end
    end
  end
end
