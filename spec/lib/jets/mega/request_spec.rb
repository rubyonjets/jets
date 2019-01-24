describe Jets::Mega::Request do
  let(:req) do
    Jets::Mega::Request.new(event, controller)
  end
  let(:event) do
    event = json_file("spec/fixtures/dumps/api_gateway/posts/show.json")
    # event['path'] = '/' # override for testing
    event
  end
  let(:controller) { PostsController.new(event, {}) }

  context "api gateway event" do
    describe "process" do
      it "sends req using net/http" do
        # Uncomment this stubbing to test live req
        # Will need a rack server up and running
        http = double(:http)
        allow(http).to receive(:open_timeout=)
        allow(http).to receive(:read_timeout=)
        resp = double(:resp).as_null_object
        allow(resp).to receive(:code).and_return("200")
        allow(resp).to receive(:each_header).and_return({})
        allow(resp).to receive(:body).and_return("test body")
        allow(http).to receive(:request).and_return(resp)
        allow(Net::HTTP).to receive(:new).and_return(http)

        resp = req.proxy
        # pp resp # uncomment to see and debug
        expect(resp).to eq({:status=>200, :headers=>{}, :body=>"test body"})
      end
    end
  end
end
