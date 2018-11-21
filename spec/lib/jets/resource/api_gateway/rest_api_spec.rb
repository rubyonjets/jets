describe Jets::Resource::ApiGateway::RestApi do

  context 'endpoint configuration' do
    it 'defaults to edge-optimized' do
      expect(Jets::Resource::ApiGateway::RestApi.new(endpoint_type: nil).properties["EndpointConfiguration"]["Types"][0]).to eq 'EDGE'
    end

    it 'can be set explicitly' do
      expect(Jets::Resource::ApiGateway::RestApi.new(endpoint_type: 'PRIVATE').properties["EndpointConfiguration"]["Types"][0]).to eq 'PRIVATE'
    end
  end

end

