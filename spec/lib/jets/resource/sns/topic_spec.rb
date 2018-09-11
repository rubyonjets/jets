describe Jets::Resource::Sns::Topic do
  let(:resource) { Jets::Resource::Sns::Topic.new(definition) }

  context "properties only" do
    let(:definition) do
      {
        display_name: "hi there",
        topic_name: "hello world",
      }
    end

    it "definition" do
      # pp resource.logical_id # uncomment to debug
      expect(resource.logical_id).to eq "SharedSnsTopic"
      # pp resource.definition # uncomment to debug
      # pp resource.properties # uncomment to debug
      properties = resource.properties
      expect(properties['DisplayName']).to eq "hi there"
      expect(properties['TopicName']).to eq "hello world"
    end

    it "counter" do
      resource = Jets::Resource::Sns::Topic.new(definition)
      resource.counter # second time
      expect(resource.counter).to eq(2)
      expect(resource.logical_id).to eq "SharedSnsTopic2"
    end

    it "full_definition?" do
      expect(resource.full_definition?).to be false
    end
  end

  context "full definition" do
    let(:definition) do
      {
        my_sns_topic: {
          type: "AWS::Sns::Topic",
          properties: {
            display_name: "cool topic"
          }
        }
      }
    end

    it "template" do
      puts "resource.logical_id #{resource.logical_id}"
      expect(resource.logical_id).to eq("SharedResourceMySnsTopic")
    end

    it "full_definition?" do
      expect(resource.full_definition?).to be true
    end
  end
end
