describe Jets::Shim::Adapter::Alb do
  describe "alb" do
    let :adapter do
      described_class.new(event)
    end
    let :event do
      JSON.load(IO.read("spec/fixtures/shim/events/alb.json"))
    end

    it "transforms event to rack env" do
      env = adapter.to_rack_env
      expect(env["REQUEST_METHOD"]).to eq "POST"
      expect(env["PATH_INFO"]).to eq "/path/to/resource"
      expect(env["QUERY_STRING"]).to eq "query=1234ABCD"
    end
  end
end
