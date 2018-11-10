describe Jets::Controller::Middleware::Main do
  let(:main) { Jets::Controller::Middleware::Main.new(rack_env) }
  let(:rack_env) do
    env = Jets::Controller::Rack::Env.new(event, context).convert
    route = Jets::Controller::Middleware::Local::RouteMatcher.new(env).find_route
    mimic = Jets::Controller::Middleware::Local::MimicAwsCall.new(route, env)
    env.merge!(mimic.vars)
    env
  end
  let(:context) { nil }

  context "posts index" do
    let(:event) { json_file("spec/fixtures/dumps/api_gateway/posts/index.json") }

    it "call" do
      triplet = Jets::Controller::Middleware::Main.call(rack_env)
      status, headers, body = triplet
      expect(status).to eq "200"
      expect(headers).to be_a(Hash)
      expect(body.read).to eq "{\"action\":\"index\",\"posts\":[]}"
    end
  end
end
