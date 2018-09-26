require "json"

# puts "loading function"

def handle(event, context)
  # puts "value1 = #{event['key1']}"
  # puts "value2 = #{event['key2']}"
  # puts "value3 = #{event['key3']}"

  "hello world: #{event['key1'].inspect}" # Echo back the first key value
  # raise "Something went wrong"
end
