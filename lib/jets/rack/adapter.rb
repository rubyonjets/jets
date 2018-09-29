module Jets::Rack
  class Adapter
    extend Memoist

    attr_reader :event
    def initialize(event, context={})
      @event = event
    end

    def process
      app = Rails.application
      triplet = app.call(rack_env)
      convert_to_api_gateway(triplet) # resp
    end

    def rack_env
      builder = Env.new(event)
      builder.build
    end
    memoize :env

    def convert_to_api_gateway(triplet)
      builder = Jets::Rack::ApiGateway.new(triplet)
      builder.build # resp
    end
  end
end
