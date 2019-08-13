describe Jets::Resource::ApiGateway::RestApi do

  context 'endpoint configuration' do
    let(:endpoint_types) do
      Jets::Resource::ApiGateway::RestApi.new.properties["EndpointConfiguration"]["Types"]
    end

    it 'defaults to edge-optimized' do
      allow(Jets.config.api).to receive(:endpoint_type).and_return('EDGE')
      expect(endpoint_types).to eq ['EDGE']
    end

    it 'can be set explicitly' do
      allow(Jets.config.api).to receive(:endpoint_type).and_return('PRIVATE')
      expect(endpoint_types).to eq ['PRIVATE']
    end
  end

  context "policy configuration" do
    let(:endpoint_policy) do
      Jets::Resource::ApiGateway::RestApi.new.properties["Policy"]
    end

    it 'defaults to nil' do
      expect(endpoint_policy).to be_nil
    end

    it 'can be set explicitly' do
      allow(Jets.config.api).to receive(:endpoint_policy).and_return(version: "2012-10-17")
      expect(endpoint_policy).to a_hash_including("Version" => "2012-10-17")
    end
  end
end
