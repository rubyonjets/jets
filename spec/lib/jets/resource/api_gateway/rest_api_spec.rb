describe Jets::Resource::ApiGateway::RestApi do

  context 'endpoint configuration' do
    let(:endpoint_config) do
      Jets::Resource::ApiGateway::RestApi.new.properties['EndpointConfiguration']
    end

    context 'type' do
      let(:endpoint_types) { endpoint_config['Types'] }

      it 'defaults to edge-optimized' do
        allow(Jets.config.api).to receive(:endpoint_type).and_return('EDGE')
        expect(endpoint_types).to eq ['EDGE']
      end

      it 'can be set explicitly' do
        allow(Jets.config.api).to receive(:endpoint_type).and_return('PRIVATE')
        expect(endpoint_types).to eq ['PRIVATE']
      end
    end

    context 'vpc endpoint ids' do
      let(:vpc_endpoint_ids) { endpoint_config['VpcEndpointIds'] }

      it 'defaults to nil' do
        expect(vpc_endpoint_ids).to be_nil
      end

      it 'can be set explicitly' do
        allow(Jets.config.api).to receive(:vpc_endpoint_ids).and_return(['vpce-1234'])
        expect(vpc_endpoint_ids).to eq ['vpce-1234']
      end
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
