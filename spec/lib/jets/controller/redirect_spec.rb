class RedirectionController < Jets::Controller::Base
end

describe RedirectionController do
  let(:controller) { RedirectionController.new(event, context, meth) }
  let(:context) { nil }
  let(:meth) { "index" }

  context "localhost" do
    context "rack headers with Host and origin" do
      # the fixture uses actual data capture from a local request
      let(:event) do
        json_file("spec/fixtures/dumps/rack/posts/create.json")
      end
      it "redirect_to" do
        resp = controller.send(:redirect_to, "/myurl", status: 301)
        redirect_url = resp["headers"]["Location"]
        expect(redirect_url).to eq "http://localhost:8888/myurl"
      end
    end
  end

  context "amazonaws.com" do
    context "api gateway headers with Host and X-Forwarded-Proto" do
      # the fixture uses actual data capture from a api gateay request
      let(:event) do
        json_file("spec/fixtures/dumps/api_gateway/posts/create.json")
      end
      it "redirect_to adds the stage name to the url" do
        resp = controller.send(:redirect_to, "/myurl", status: 301)
        redirect_url = resp["headers"]["Location"]
        expect(redirect_url).to eq "https://8s1wzivnz4.execute-api.us-east-1.amazonaws.com/test/myurl"
      end
    end
  end
end
