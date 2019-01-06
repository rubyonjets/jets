describe Jets::Resource::ApiGateway::RestApi do
  let(:logical_id) do
    logical_id = Jets::Resource::ApiGateway::RestApi::LogicalId.new
    allow(logical_id).to receive(:current).and_return("RestApi")
    logical_id
  end

  context "changes detected" do
    it "get" do
      allow(logical_id).to receive(:changed?).and_return(true)
      allow(logical_id).to receive(:stack_exists?).and_return(true)
      allow(logical_id).to receive(:api_gateway_exists?).and_return(true)
      expect(logical_id.get).to eq "RestApi1"
    end
  end

  context "no changes detected" do
    it "get" do
      allow(logical_id).to receive(:changed?).and_return(false)
      expect(logical_id.get).to eq "RestApi"
    end
  end
end
