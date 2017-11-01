def create(event, context)
  puts "event #{event.inspect}"
  puts "context #{context.inspect}"

  # Can return anything for simple function case
  puts "event #{event.inspect}"
  puts "JSON.dump(event) #{JSON.dump(event).inspect}"
  # event # return response back to Lambda and then API Gateway
  "function test" # this works
end
