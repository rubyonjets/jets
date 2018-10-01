require 'net/http'

class Jets::RackController < Jets::Rack::AdapterController
  # Megamode
  def process
    resp = rack_request
    render(resp)
  end

private

  def rack_request
    Jets::Rack::Request.new(event, request).send
  end

end