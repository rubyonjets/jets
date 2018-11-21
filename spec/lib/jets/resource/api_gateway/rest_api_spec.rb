describe Jets::Resource::ApiGateway::RestApi do

  context 'endpoint configuration' do
    let(:types) do
      Jets::Resource::ApiGateway::RestApi.new.properties["EndpointConfiguration"]["Types"]
    end
    
    it 'defaults to edge-optimized' do
      allow(Jets.config.api).to receive(:endpoint_type).and_return(nil)
      expect(types).to eq ['EDGE']
    end

    it 'can be set explicitly' do
      allow(Jets.config.api).to receive(:endpoint_type).and_return('PRIVATE')
      expect(types).to eq ['PRIVATE']
    end
  end

end

