class Jets::RackController < Jets::Rack::AdapterController
  def process
    triplet = app.call(rack_env)
    resp = convert_to_api_gateway(triplet) # resp
    # render json: resp
    render status: resp['statusCode'],
           headers: resp['headers'],
           body: resp['body']
  end
end