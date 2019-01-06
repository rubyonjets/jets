describe Jets::Middleware::DefaultStack do
  let(:default_stack) { Jets::Middleware::DefaultStack.new(Jets.application, Jets.config) }
  context "default_stack" do
    it "build_stack" do
      stack = default_stack.build_stack
      middlewares = stack.instance_variable_get(:@middlewares)
      expect(middlewares).to include(Rack::Runtime)
    end

    it "session store" do
      session_store = default_stack.send(:session_store)
      expect(session_store).to eq Rack::Session::Cookie
    end
  end
end
