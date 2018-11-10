describe Jets::Controller::Rack::Adapter do
  let(:adapter) { Jets::Controller::Rack::Adapter.new(event, context, meth) }
  let(:context) { nil }

  context "general" do
    let(:event) { json_file("spec/fixtures/dumps/api_gateway/posts/index.json") }
    let(:meth)  { :index }
    it "convert" do
      result = adapter.process
      env = adapter.env
      expect(env).to be_a(Hash)
      expect(env['REQUEST_METHOD']).to eq "GET"
      expect(env['SERVER_NAME']).to eq("uhghn8z6t1.execute-api.us-east-1.amazonaws.com")
      expect(env['QUERY_STRING']).to eq("")
      expect(env['PATH_INFO']).to eq("/posts")
      expect(env['REMOTE_ADDR']).to eq("69.42.1.180, 54.239.203.100")
      expect(env['REQUEST_URI']).to eq("https://uhghn8z6t1.execute-api.us-east-1.amazonaws.com/posts")
      expect(env['HTTP_USER_AGENT']).to eq("PostmanRuntime/6.4.1")
    end
  end
end
