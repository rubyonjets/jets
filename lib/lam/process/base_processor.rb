require 'json'
require_relative 'infer'

# Global overrides for Lambda processing
$stdout.sync = true
# This might seem weird but we want puts to write to stderr which is set in
# the node shim to write to stderr.  This directs the output to Lambda logs.
# Printing to stdout can managle up the payload returned from Lambda function.
# This is not desired if you want to return say a json payload to API Gateway
# eventually.
def puts(text)
  $stderr.puts(text)
end

class Lam::Process::BaseProcessor
  attr_reader :event, :context, :handler
  def initialize(event, context, handler)
    # assume valid json from Lambda
    @event = JSON.parse(event)
    @context = JSON.parse(context)
    @handler = handler
  end
end
