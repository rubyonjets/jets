describe Jets::Rack::Request do
  let(:request) do
    Jets::Rack::Request.new(event, controller)
  end
  let(:event) do
    event = json_file("spec/fixtures/dumps/api_gateway/posts/show.json")
    # event['path'] = '/' # override for testing
    event
  end
  let(:controller) { PostsController.new(event, {}) }

  context "api gateway event" do
    describe "process" do
      it "sends request using net/http" do
        # Uncomment this stubbing to test live request
        # Will need a rack server up and running
        http = double(:http).as_null_object
        response = double(:response).as_null_object
        allow(response).to receive(:code).and_return("200")
        allow(response).to receive(:each_header).and_return({})
        allow(response).to receive(:body).and_return("test body")
        allow(http).to receive(:request) do |get, &block|
          block.call(response)
        end
        allow(Net::HTTP).to receive(:start) do |host, port, &block|
          block.call(http)
        end

        resp = request.process
        # pp resp # uncomment to see and debug

        # http value because of stubbing
        expect(resp).to eq({:body=>http, :headers=>http, :status=>http})
      end
    end
  end
end
