describe Jets::Rack::Request do
  let(:request) do
    Jets::Rack::Request.new(event, controller_request)
  end
  let(:event) do
    event = json_file("spec/fixtures/dumps/api_gateway/posts/show.json")
    event['path'] = '/'
    event
  end
  let(:controller_request) { Jets::Controller::Request.new(event) }

  context "api gateway event" do
    describe "send" do
      it "sends request using net/http" do
        pp request.send

        # env = builder.build
        # pp env # uncomment to see and debug
        # expect(env['REQUEST_METHOD']).to eq "GET"
        # expect(env['PATH_INFO']).to eq "/posts/89"
        # expect(env['SERVER_NAME']).to eq "demo.rubyonjets.com"
        # expect(env['SERVER_PORT']).to eq "443"
      end
    end
  end
end
