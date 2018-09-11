describe Jets::Resource::Sns::Topic do
  let(:resource) { Jets::Resource::Sns::Topic.new(definition) }
  let(:definition) do
    {
      display_name: "hi there",
      topic_name: "hello world",
    }
  end

  context "resource" do
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
  end
end
