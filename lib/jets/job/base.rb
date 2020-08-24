require 'json'

# Job public methods get turned into Lambda functions.
#
# Jets::Job::Base < Jets::Lambda::Functions
# Both Jets::Job::Base and Jets::Lambda::Functions have Dsl modules included.
# So the Jets::Job::Dsl overrides some of the Jets::Lambda::Functions behavior.
module Jets::Job
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
        if on_lambda?
          function_name = "#{self.to_s.underscore}-#{meth}"
          call = Jets::Commands::Call.new(function_name, JSON.dump(event), invocation_type: "Event")
          call.run
        else
          puts "INFO: Not on AWS Lambda. In local mode perform_later executes the job with perform_now instead."
          perform_now(meth, event, context)
        end
      end

    private
      def on_lambda?
        !!ENV['AWS_LAMBDA_FUNCTION_NAME']
      end
    end
  end
end
