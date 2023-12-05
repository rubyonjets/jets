require "json"

def handle(event, context)
  "hello world: #{event['key1'].inspect}" # Echo back the first key value
end
