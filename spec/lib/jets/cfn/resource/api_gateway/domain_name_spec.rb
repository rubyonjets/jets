describe Jets::Cfn::Resource::ApiGateway::DomainName do

  context 'default' do
    let(:domain_name) do
      Jets::Cfn::Resource::ApiGateway::DomainName.new
    end

    it "domain_name" do
      allow(Jets.config.domain).to receive(:name).and_return("test.com")
      expect(domain_name.logical_id).to eq "DomainName"
      properties = domain_name.properties
      # pp properties # uncomment to debug
      expect(properties[:DomainName]).to eq "test.com"
    end
  end

end
