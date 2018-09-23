describe Jets::Resource::Standardizer do
  let(:standardizer) { Jets::Resource::Standardizer.new(definition) }

  context "long form" do
    let(:definition) do
      {
        "RestApi": {
          type: "AWS::ApiGateway::RestApi",
          properties: {
            name: "demo-test"
          }
        }
      }
    end
    it "template" do
      template = standardizer.template
      # puts template # uncomment to see and debug
      expect(template).to eq(
        {"RestApi" => {"Properties"=>{"Name"=>"demo-test"}, "Type"=>"AWS::ApiGateway::RestApi"}}
      )
    end
  end

  context "medium form" do
    let(:definition) do
      [:rest_api,
        type: "AWS::ApiGateway::RestApi",
        properties: { name: "demo-test" }
      ]
    end
    it "template" do
      template = standardizer.template
      # puts template # uncomment to see and debug
      expect(template).to eq(
        {"RestApi" => {"Properties"=>{"Name"=>"demo-test"}, "Type"=>"AWS::ApiGateway::RestApi"}}
      )
    end
  end

  context "short form" do
    let(:definition) do
      [:sns_topic, "AWS::SNS::Topic",
          display_name: "my name"]
    end
    it "template" do
      expect(standardizer.template).to eq(
        {"SnsTopic" => {"Properties"=>{"DisplayName"=>"my name"}, "Type"=>"AWS::SNS::Topic"}}
      )
    end
  end
end
