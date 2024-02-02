describe Jets::Cfn::Resource::ApiGateway::Stage do

  context 'default' do
    let(:stage) do
      Jets::Cfn::Resource::ApiGateway::Stage.new
    end

    it "stage" do
      allow(Jets.config.stage).to receive(:client_certificate).and_return(true)
      expect(stage.logical_id).to eq "Stage"
      properties = stage.properties
      # pp properties # uncomment to debug
      expect(properties[:ClientCertificateId]).to eq "!Ref ClientCertificate"
      expect(properties[:RestApiId]).to eq "!Ref RestApi"
    end
  end

  context 'client_certificate type is string' do
    let(:stage) do
      Jets::Cfn::Resource::ApiGateway::Stage.new
    end

    it "stage" do
      allow(Jets.config.stage).to receive(:client_certificate).and_return('aBcDeF')
      expect(stage.logical_id).to eq "Stage"
      properties = stage.properties
      # pp properties # uncomment to debug
      expect(properties[:ClientCertificateId]).to eq "aBcDeF"
      expect(properties[:RestApiId]).to eq "!Ref RestApi"
    end
  end
end
