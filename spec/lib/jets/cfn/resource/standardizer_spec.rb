describe Jets::Cfn::Resource::Standardizer do
  let(:standardizer) { Jets::Cfn::Resource::Standardizer.new(definition) }

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
      expect(template).to eq(
        {:RestApi=>{:Type=>"AWS::ApiGateway::RestApi", :Properties=>{:Name=>"demo-test"}}}
      )
    end
  end

  context "medium form with properties" do
    let(:definition) do
      [:rest_api,
        type: "AWS::ApiGateway::RestApi",
        properties: { name: "demo-test" }
      ]
    end
    it "template" do
      template = standardizer.template
      expect(template).to eq(
        {:RestApi=>{:Type=>"AWS::ApiGateway::RestApi", :Properties=>{:Name=>"demo-test"}}}
      )
    end
  end

  context "medium form with empty properties" do
    let(:definition) do
      [:rest_api,
        type: "AWS::ApiGateway::RestApi",
        properties: { } # empty
      ]
    end
    it "template" do
      template = standardizer.template
      expect(template).to eq(
        {:RestApi=>{:Type=>"AWS::ApiGateway::RestApi"}}
      )
    end
  end

  context "medium form with no properties" do
    let(:definition) do
      [:rest_api,
        type: "AWS::ApiGateway::RestApi"
      ]
    end
    it "template" do
      template = standardizer.template
      expect(template).to eq(
        {:RestApi=>{:Type=>"AWS::ApiGateway::RestApi"}}
      )
    end
  end

  context "short form with properties" do
    let(:definition) do
      [:sns_topic, "AWS::SNS::Topic",
          display_name: "my name"]
    end
    it "template" do
      expect(standardizer.template).to eq(
        {:SnsTopic=>{:Type=>"AWS::SNS::Topic", :Properties=>{:DisplayName=>"my name"}}}
      )
    end
  end

  context "short form with empty properties" do
    let(:definition) do
      [:sns_topic, "AWS::SNS::Topic", {}]
    end
    it "template" do
      puts standardizer.template
      expect(standardizer.template).to eq(
        {:SnsTopic=>{:Type=>"AWS::SNS::Topic"}}
      )
    end
  end

  context "short form with no properties" do
    let(:definition) do
      [:sns_topic, "AWS::SNS::Topic"]
    end
    it "template" do
      expect(standardizer.template).to eq(
        {:SnsTopic=>{:Type=>"AWS::SNS::Topic"}}
      )
    end
  end
end
