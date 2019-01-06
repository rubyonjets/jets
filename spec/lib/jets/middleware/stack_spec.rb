describe Jets::Middleware::Stack do
  context "stack" do
    it "build" do
      default_stack = Jets::Middleware::DefaultStack.new(Jets.config, Jets.application).build_stack
      endpoint = Jets::Controller::Middleware::Main
      middleware = default_stack.build(endpoint) # uncomment to see middleware tree
      # pp middleware # uncomment to see and debug
      expect(middleware).to be_a Rack::Runtime # top of the tree
      # $ jets middleware
      # use Rack::Runtime
      # use Rack::MethodOverride
      # use Jets::Controller::Middleware::Local
      # use Rack::Session::Cookie
      # use Rack::Head
      # use Rack::ConditionalGet
      # use Rack::ETag
      # run Jets::Controller::Middleware::Main
    end
  end
end
