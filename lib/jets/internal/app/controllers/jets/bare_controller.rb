# Parent class for MountController and RackController
class Jets::BareController < Jets::Controller::Base
  layout false
  internal true
  skip_forgery_protection

private
  # Override process! so it doesnt go through the complete Jets project middleware stack which could interfer with
  # the mounted Rack app.
  def process!
    status, headers, body = dispatch!
    # Use the adapter only to convert the Rack triplet to a API Gateway hash structure
    adapter = Jets::Controller::Rack::Adapter.new(event, context, meth)
    adapter.convert_to_api_gateway(status, headers, body)
  end
end