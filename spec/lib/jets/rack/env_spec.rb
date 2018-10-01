describe Jets::Rack::Env do
  let(:builder) do
    Jets::Rack::Env.new(event)
  end

  context "aws lambda proxy" do
    let(:event) { json_file("spec/fixtures/dumps/api_gateway/posts/show.json") }
    describe "build" do
      it "converts event to rack env hash" do
        env = builder.build
        pp env # uncomment to see and debug
        expect(env['REQUEST_METHOD']).to eq "GET"
        expect(env['PATH_INFO']).to eq "/posts/89"
        expect(env['SERVER_NAME']).to eq "demo.rubyonjets.com"
        expect(env['SERVER_PORT']).to eq "443"
      end
    end
  end
end
