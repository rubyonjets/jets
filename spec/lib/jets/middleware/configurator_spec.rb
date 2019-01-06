describe Jets::Middleware::Configurator do
  context "configurator" do
    it "middlewares operations" do
      middleware1 = Jets::Middleware::Configurator.new
      middleware1.use Rack::Runtime
      middleware1.use Rack::ConditionalGet
      middleware1.insert_before Rack::Runtime, Rack::Head
      middleware1.swap Rack::ConditionalGet, Rack::ETag

      middleware2 = Jets::Middleware::Configurator.new
      middleware2.use Rack::MethodOverride
      middleware2.use Rack::TempfileReaper

      middleware3 = middleware1 + middleware2
      # pp middleware3 # uncomment to see and debug
      operations = middleware3.instance_variable_get(:@operations)
      expect(operations.size).to eq 6
    end

    let(:rack_env) do
      event = json_file("spec/fixtures/dumps/api_gateway/posts/index.json")
      context = nil
      env = Jets::Controller::Rack::Env.new(event, context).convert
      route = Jets::Controller::Middleware::Local::RouteMatcher.new(env).find_route
      mimic = Jets::Controller::Middleware::Local::MimicAwsCall.new(route, env)
      env.merge!(mimic.vars)
      env
    end

    it "call" do
      default_stack = Jets::Middleware::DefaultStack.new(Jets.config, Jets.application).build_stack
      config_middleware = Jets::Middleware::Configurator.new
      config_middleware.use Rack::TempfileReaper

      middleware = config_middleware.merge_into(default_stack)
      stack = middleware.build(Jets::Controller::Middleware::Main)
      status, headers, body = stack.call(rack_env)
      expect(status).to eq "200"
      expect(headers).to be_a(Hash)
      expect(body).to respond_to(:each)
    end
  end
end
