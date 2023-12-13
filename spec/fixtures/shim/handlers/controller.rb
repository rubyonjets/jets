require "bundler/setup"
require "jets/shim"

Jets::Shim.boot

def lambda_handler(event:, context:)
  Jets::Shim.handler(event, context)
end

if __FILE__ == $0
  event_path = ENV["EVENT"]
  event = if event_path && File.exist?(event_path)
    JSON.load(IO.read(event_path))
  else
    # APIGW
    {
      path: "/posts",
      httpMethod: "GET",
      headers: {
        Host: "foobar.execute-api.us-west-2.amazonaws.com"
      }
    }
  end
  resp = lambda_handler(event: event, context: {})
  puts "resp: "
  pp resp
end
