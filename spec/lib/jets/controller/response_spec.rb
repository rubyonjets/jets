describe Jets::Controller::Response do
  let(:response) { Jets::Controller::Response.new(event) }

  context "books" do
    let(:event) { json_file("spec/fixtures/dumps/api_gateway/books/list.json") }

    it "headers" do
      expect(response.headers).to eq({})
      response.headers["Set-Cookie"] = "foo=bar"
      expect(response.headers).to eq({"Set-Cookie" => "foo=bar"})
    end
  end
end
