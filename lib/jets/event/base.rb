require "json"

# Event public methods get turned into Lambda functions.
#
# Jets::Event::Base < Jets::Lambda::Functions
# Both Jets::Event::Base and Jets::Lambda::Functions have Dsl modules included.
# So the Jets::Event::Dsl overrides some of the Jets::Lambda::Functions behavior.
module Jets::Event
  class Base < Jets::Lambda::Functions
    class Error < StandardError; end

    include Dsl

    # non-DSL methods
    include Helpers::KinesisEvent
    include Helpers::LogEvent
    include Helpers::S3Event
    include Helpers::SnsEvent
    include Helpers::SqsEvent
    prepend Jets::ExceptionReporting::Process

    class << self
      include Jets::Util::Logging

      def handle(event, context, meth = :perform)
        runner = new(event, context, meth)
        runner.send(meth)
      end

      def handle_now(meth = :handle, event = {}, context = {})
        handle(event, context, meth)
      end

      def handle_later(meth = :handle, event = {}, context = {})
        function = "#{name.underscore}-#{meth}" # IE: "cool_event-handle"
        call = Jets::CLI::Call.new(
          function: function,
          event: JSON.dump(event),
          invocation_type: "Event"
        )
        resp = begin
          call.invoke
        rescue Jets::CLI::Call::Error => e
          puts "ERROR: #{e.message}".color(:red)
          puts "The stack may not be full deployed yet.  Please check the stack and try again."
          return
        end
        unless resp.status_code == 202
          raise Error, "Error calling Lambda function #{function} with invocation_type Event. status code: #{resp.status_code}"
        end
        resp
      end
    end
  end
end
