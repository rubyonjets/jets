module Jets::Rack
  class Env
    def initialize(event)
      @event = event
    end

    def build
      {
        REQUEST_METHOD: "xxx",
        PATH_INFO: "xxx",
        QUERY_STRING: "xxx",
        SERVER_NAME: "xxx",
        SERVER_PORT: "xxx",
        "rack.version": "xxx",
        "rack.url_scheme": "xxx",
        "rack.input": "xxx",
        "rack.errors": "xxx",
        "rack.session": "xxx",
        "rack.logger": "xxx",
      }.stringify_keys
    end
  end
end