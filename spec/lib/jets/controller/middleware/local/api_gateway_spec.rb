describe Jets::Controller::Middleware::Local::ApiGateway do
  let(:route) do
    Jets::Controller::Middleware::Local::RouteMatcher.new(env).find_route
  end
  let(:env) do
    { "PATH_INFO" => "/posts/tung/edit", "REQUEST_METHOD" => "GET" }
  end

  it "call" do
    api_gateway = Jets::Controller::Middleware::Local::ApiGateway.new(route, env)
    expect(api_gateway.event).to be_a(Hash)
  end
end
