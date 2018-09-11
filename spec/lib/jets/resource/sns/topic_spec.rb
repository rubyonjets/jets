describe Jets::Resource::Sns::Topic do
  let(:resource) { Jets::Resource::Sns::Topic.new(shared_class, definition) }
  let(:shared_class) { "Resource" }

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

    it "counter" do
      resource = Jets::Resource::Sns::Topic.new(shared_class, definition)
      resource.counter # first time
      resource = Jets::Resource::Sns::Topic.new(shared_class, definition)
      resource.counter # second time
      expect(resource.counter).to eq(2)
      expect(resource.logical_id).to eq "SharedResourceMySnsTopic2"
    end

    it "full_definition?" do
      expect(resource.full_definition?).to be true
    end
  end
end
