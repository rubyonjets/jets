class Jets::RackController < Jets::Controller::Base
  layout false
  internal true

  # Megamode
  def process
    resp = rack_request
    render(resp)
  end

private

  def rack_request
    Jets::Rack::Request.new(event, self).process
  end

end