describe Jets::Controller::Middleware::Main do
  before(:each) { silence_loggers! }
  after(:each)  { restore_loggers! }

  let(:main) { Jets::Controller::Middleware::Main.new(rack_env) }
  let(:rack_env) do
    rack_env = Jets::Controller::RackAdapter::Env.new(event, context).convert

    route = Jets::Router::Matcher.new.find_by_env(rack_env)
    apigw = Jets::Controller::Middleware::Mimic::Apigw.new(route, rack_env)

    rack_env.merge!(
      'jets.controller' => apigw.controller, # mimic controller instance
      'jets.context'    => apigw.context,    # mimic context
      'jets.event'      => apigw.event,      # mimic event
      'jets.meth'       => apigw.meth,
    )

    apigw.controller.define_singleton_method(:commit_flash) do
      # noop hack to avoid commit_flash call.
      # Since not full middleware stack is setup in this test
    end

    rack_env
  end
  let(:context) { nil }

  context "posts index" do
    let(:event) { json_file("spec/fixtures/dumps/api_gateway/posts/index.json") }

    it "call" do
      triplet = Jets::Controller::Middleware::Main.call(rack_env)
      status, headers, body = triplet
      expect(status).to eq 200
      expect(headers).to be_a(Hash)
      expect(body.first).to eq "{\"action\":\"index\",\"posts\":[]}"
    end
  end
end
