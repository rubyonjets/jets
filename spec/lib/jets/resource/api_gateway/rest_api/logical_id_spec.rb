describe Jets::Resource::ApiGateway::RestApi do
  let(:logical_id) do
    logical_id = Jets::Resource::ApiGateway::RestApi::LogicalId.new
    allow(logical_id).to receive(:current).and_return("RestApi")
    logical_id
  end
  let(:detection) do
    detection = double(:detection)
    allow(detection).to receive(:changed?).and_return(changed)
    detection
  end

  context "changes detected" do
    let(:changed) { true }

    it "get" do
      allow(Jets::Resource::ApiGateway::RestApi::ChangeDetection).to receive(:new).and_return(detection)
      expect(logical_id.get).to eq "RestApi1"
    end
  end

  context "no changes detected" do
    let(:changed) { false }

    it "get" do
      allow(Jets::Resource::ApiGateway::RestApi::ChangeDetection).to receive(:new).and_return(detection)
      expect(logical_id.get).to eq "RestApi"
    end
  end
end
