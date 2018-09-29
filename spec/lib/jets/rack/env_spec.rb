describe Jets::Rack::Env do
  let(:builder) do
    Jets::Rack::Env.new(event)
  end

  context "aws lambda proxy" do
    let(:event) { json_file("spec/fixtures/dumps/api_gateway/request.json") }
    describe "build" do
      it "converts event to rack env hash" do
        env = builder.build
        pp env
      end
    end
  end
end
