describe Jets::Middleware::Stack do
  context "stack" do
    it "build" do
      default_stack = Jets::Middleware::DefaultStack.new(Jets.config, Jets.application).build_stack
      endpoint = Jets::Controller::Rack::Main
      middleware = default_stack.build(endpoint) # uncomment to see middleware tree
      # pp middleware # uncomment to see and debug
      expect(middleware).to be_a Jets::Controller::Middleware::Local # top of the tree
    end
  end
end
