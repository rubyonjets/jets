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
        puts "The default fallback handler is being called because a handler for it could not be found"
        puts "For debugging, here is the"
        if ENV["_HANDLER"] # on AWS Lambda
          puts "event: #{JSON.dump(event)}"
        else
          puts "event:"
          puts JSON.pretty_generate(event)
        end
        puts "Please double check the event payload.\n\n"

        if target
          puts "ERROR: event handler target not found: #{target}".color(:red)
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
            You can also configure a custom fallback handler in the config/jets/shim.rb file.
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
          errorMessage: "event handler not found. Look at logs for details",
          errorType: "JetsEventHandlerNotFound"
        }
      end
    end
  end
end
