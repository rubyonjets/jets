require "spec_helper"

describe Jets::Controller::Request do
  let(:request) { Jets::Controller::Request.new(event) }

  context "general" do
    let(:event) { json_file("spec/fixtures/dumps/lambda/xhr-delete.json") }

    it "xhr" do
      expect(request.xhr?).to be true
    end

    it "host" do
      expect(request.host).to eq "localhost:8888"
    end

    it "origin" do
      expect(request.origin).to eq "http://localhost:8888"
    end
  end
end
