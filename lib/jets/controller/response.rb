class Jets::Controller
  class Response
    attr_reader :headers
    def initialize(event)
      @event = event
      @headers = {}
    end

    def set_header(k,v)
      @headers[k] = v
    end
  end
end