class Jets::RackController < Jets::BareController
  # Megamode
  def process
    resp = mega_request
    render(resp)
  end

private
  def mega_request
    Jets::Mega::Request.new(event, self).proxy
  end
end