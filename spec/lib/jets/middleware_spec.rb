class MiddlewareTestClass
  include Jets::Middleware
end

describe Jets::Middleware do
  let(:env) do
    event = json_file("spec/fixtures/dumps/api_gateway/posts/index.json")
    context = nil
    env = Jets::Controller::Rack::Env.new(event, context).convert
    mimic = Jets::Controller::Middleware::Local::MimicAwsCall.new(env)
    env.merge!(mimic.vars)
    env
  end

  context "middleware" do
    it "call" do
      status, headers, body = MiddlewareTestClass.new.call(env)
      expect(status).to eq "200"
    end
  end
end
