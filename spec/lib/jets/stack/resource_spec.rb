describe "Stack resource" do
  let(:resource) { Jets::Stack::Resource.new("ExampleStack", definition) }

  context "long form" do
    let(:definition) do
      {
        sns_topic: {
          type: "AWS::SNS::Topic",
          properties: {
            description: "my desc",
            display_name: "my name",
          }
        }
      }
    end
    it "template" do
      expect(resource.template).to eq(
        {"SnsTopic" => {"Properties"=>{"Description"=>"my desc", "DisplayName"=>"my name"}, "Type"=>"AWS::SNS::Topic"}}
      )
    end
  end

  context "medium form with properties" do
    let(:definition) do
      [:sns_topic,
        type: "AWS::SNS::Topic",
        properties: {
          display_name: "my name",
        }]
    end
    it "template" do
      expect(resource.template).to eq(
        {"SnsTopic"=>{"Properties"=>{"DisplayName"=>"my name"}, "Type"=>"AWS::SNS::Topic"}}
      )
    end
  end

  context "medium form with empty properties" do
    let(:definition) do
      [:sns_topic,
        type: "AWS::SNS::Topic",
        properties: {}]
    end
    it "template" do
      expect(resource.template).to eq(
        {"SnsTopic"=>{"Type"=>"AWS::SNS::Topic"}}
      )
    end
  end

  context "medium form without properties" do
    let(:definition) do
      [:sns_topic,
        type: "AWS::SNS::Topic"]
    end
    it "template" do
      expect(resource.template).to eq(
        {"SnsTopic"=>{"Type"=>"AWS::SNS::Topic"}}
      )
    end
  end

  context "medium form with empty properties" do
    let(:definition) do
      [:sns_topic,
        type: "AWS::SNS::Topic",
        properties: {}]
    end
    it "template" do
      expect(resource.template).to eq(
        {"SnsTopic"=>{"Type"=>"AWS::SNS::Topic"}}
      )
    end
  end

  context "short form with properties" do
    let(:definition) do
      [:sns_topic, "AWS::SNS::Topic",
          display_name: "my name"]
    end
    it "template" do
      expect(resource.template).to eq(
        {"SnsTopic" => {"Properties"=>{"DisplayName"=>"my name"}, "Type"=>"AWS::SNS::Topic"}}
      )
    end
  end

  context "short form without properties" do
    let(:definition) do
      [:sns_topic, "AWS::SNS::Topic"]
    end
    it "template" do
      expect(resource.template).to eq(
        {"SnsTopic" => {"Type"=>"AWS::SNS::Topic"}}
      )
    end
  end

  context "short form with empty properties" do
    let(:definition) do
      [:sns_topic, "AWS::SNS::Topic", {}]
    end
    it "template" do
      expect(resource.template).to eq(
        {"SnsTopic" => {"Type"=>"AWS::SNS::Topic"}}
      )
    end
  end
end
