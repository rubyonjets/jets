describe Jets::Controller::Request do
  let(:request) { Jets::Controller::Request.new(event, context=nil) }

  context "ajax request" do
    let(:event) { json_file("spec/fixtures/dumps/api_gateway/xhr-delete.json") }

    it "xhr" do
      expect(request.xhr?).to be true
    end

    it "host" do
      expect(request.host).to eq "localhost"
    end

    it "path" do
      expect(request.path).to eq("/articles/5")
    end

    it "headers" do
      expect(request.headers).to be_a(Hash)
    end

    it "cookies" do
      expect(request.cookies).to be_a(Hash)
    end

    it "script_name" do
      expect(request.script_name).to eq ''
    end
  end

  context "posts" do
    let(:event) { json_file("spec/fixtures/dumps/api_gateway/posts/index.json") }

    it "ssl?" do
      expect(request.ssl?).to be true
    end
  end

  context "request with cookie" do
    let(:event) { json_file("spec/fixtures/dumps/api_gateway/request-with-cookies.json") }

    it "ssl?" do
      expect(request.cookies).to be_a(Hash)
    end
  end
end
