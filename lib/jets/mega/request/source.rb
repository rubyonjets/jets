class Jets::Mega::Request
  class Source
    def initialize(event)
      @event = event
      env = Jets::Controller::Rack::Env.new(@event, {}).convert # convert to Rack env
      @source_request = Rack::Request.new(env)
    end

    def body
      if @source_request.body.respond_to?(:read)
        body = @source_request.body.read
        @source_request.body.rewind
      end
      body
    end

    def content_length
      @source_request.content_length.to_i
    end
  end
end
