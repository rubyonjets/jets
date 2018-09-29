describe Jets::Rack::Adapter do
  let(:adapter) { Jets::Rack::Adapter.new(event) }

  context "lambda proxy event" do
    let(:event) { {} }
    it "rack_env" do
      pp adapter.rack_env
    end
  end
end
