describe Jets::Controller::Middleware::Mimic::Apigw do
  let(:route) do
    matcher = Jets::Router::Matcher.new
    matcher.find_by_env(env) # simpler version does not check constraints
  end
  let(:env) do
    { "PATH_INFO" => "/posts/tung/edit", "REQUEST_METHOD" => "GET" }
  end

  it "call" do
    api_gateway = Jets::Controller::Middleware::Mimic::Apigw.new(route, env)
    expect(api_gateway.event).to be_a(Hash)
  end
end
