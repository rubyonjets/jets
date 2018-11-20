describe Jets::Middleware::Layer do
  context "layer" do
    it "build" do
      layer = Jets::Middleware::Layer.new(Rack::Runtime, {}, nil)
      middleware = layer.build(Proc.new {})
      expect(middleware).to be_a(Rack::Runtime)
    end
  end
end
