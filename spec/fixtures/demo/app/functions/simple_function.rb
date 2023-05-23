require "json"

def handler(event, context)
  "simple handler: #{event['key1'].inspect}" # Echo back the first key value
end
