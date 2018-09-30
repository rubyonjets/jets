module Jets::Rack
  class Env
    def initialize(event)
      @event = event
    end

    def build
      # pp @event
      {
        REQUEST_METHOD: @event['httpMethod'],
        PATH_INFO: @event['path'],
        QUERY_STRING: @event['queryStringParameters'],
        SERVER_NAME: @event['headers']['Host'],
        SERVER_PORT: @event['headers']['X-Forwarded-Port'],
        "rack.version": [1, 3],
        "rack.url_scheme": @event['headers']['X-Forwarded-Proto'],
        "rack.input": "xxx", # TODO: make input data work #<Rack::Lint::InputWrapper:0x00007efdcdebdbe8>
        "rack.errors": "xxx", # TODO: we need #<Rack::Lint::ErrorWrapper:0x00007efdcdebdbc0>
      }.stringify_keys
    end
  end
end