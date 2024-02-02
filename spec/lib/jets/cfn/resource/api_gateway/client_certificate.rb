describe Jets::Cfn::Resource::ApiGateway::ClientCertificate do

  context 'default' do
    let(:client_certificate) do
      Jets::Cfn::Resource::ApiGateway::ClientCertificate.new
    end

    it "client_certificate" do
      expect(client_certificate.logical_id).to eq "ClientCertificate"
    end
  end

end
