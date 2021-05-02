describe Jets::Controller::Rack::Env do
  let(:rack_env) { Jets::Controller::Rack::Env.new(event, context) }
  let(:context) { nil }

  context "books list" do
    let(:event) { json_file("spec/fixtures/dumps/api_gateway/books/list.json") }
    it "convert" do
      env = rack_env.convert
      # pp env # uncomment to debug
      expect(env).to be_a(Hash)
      expect(env['REQUEST_METHOD']).to eq "GET"
      expect(env['SERVER_NAME']).to eq("uhghn8z6t1.execute-api.us-east-1.amazonaws.com")
      expect(env['QUERY_STRING']).to eq("a=1&b=2")
      expect(env['PATH_INFO']).to eq("/books/list")
      expect(env['REMOTE_ADDR']).to eq("69.42.1.180, 54.239.203.100")
      expect(env['REQUEST_URI']).to eq("https://uhghn8z6t1.execute-api.us-east-1.amazonaws.com/books/list?a=1&b=2")
      expect(env['HTTP_USER_AGENT']).to eq("PostmanRuntime/6.4.1")
      expect(env['CONTENT_TYPE']).to eq("text/plain")
      expect(env["rack.input"]).not_to be nil
    end
  end

  context "empty body" do
    let(:event) { json_file("spec/fixtures/dumps/api_gateway/posts/show.json") }
    it "convert" do
      env = rack_env.convert
      # pp env # uncomment to debug
      expect(env).to be_a(Hash)
      expect(env['REQUEST_METHOD']).to eq "GET"
      # Rack always assigns an StringIO to "rack.input"
      expect(env["rack.input"]).not_to be nil
    end
  end
end
