module Jets::Rack
  class Adapter
    attr_reader :event
    def initialize(event, context={})
      @event = event
    end

    def rack_env
      @event
    end
  end
end