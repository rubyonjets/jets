module Jets::Shim::Adapter
  class Fallback < Base
    def handle
      fallback_handler.handler(event, context, target)
    end

    def fallback_handler
      Jets::Shim.config.fallback_handler || self.class
    end
    memoize :fallback_handler

    class << self
      def handler(event, context = nil, target = nil)
        puts <<~EOL
          WARN: handler for it could not be found. The default fallback handler is being used.
          The default fallback handler simply prints out the event payload for debugging, it will be printed below.
          Usually the default handler is not what you want.
          You might be using a test event payload for testing which does not represent a real event.
          Please double check the event payload.
        EOL
        if ENV["_HANDLER"] # on AWS Lambda
          puts "event: #{JSON.dump(event)}"
        else
          puts "event:"
          puts JSON.pretty_generate(event)
        end

        if target
          puts "WARN: Event handler target not found: #{target}".color(:red)
          target_class, target_method = target.split(".")
          target_class = target_class.camelize
          target_method ||= "perform"
          puts <<~EOL
            You can configure define an app/events handler in your application. Example:

            app/events/#{target_class.underscore}.rb

                class #{target_class} < ApplicationEvent
                  def #{target_method}
                    puts "event #{JSON.dump(event)}"
                  end
                end
          EOL

        else
          puts <<~EOL
            You can also configure a custom fallback handler with a config/jets/shim.rb file.
            Though custom handlers rarely needed and you should double check the event payload.
            Example:

            config/jets/shim.rb

                Jets.shim.configure do |config|
                  config.fallback_handler = FallbackHandler
                end

            FallbackHandler should implement handler(event, context)

          EOL
        end
        # Custom Jets error message
        {
          errorMessage: "Event handler not found. Look at logs for details",
          errorType: "JetsEventHandlerNotFound"
        }
      end
    end
  end
end
