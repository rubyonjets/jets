describe Jets::SharedResource::Sns do
  let(:sns) { Jets::SharedResource::Sns.new(shared_class) }
  let(:shared_class) { "Resource" }

  context "example shared resource" do
    it "topic" do
      resource = sns.topic("my_sns_topic", display_name: "cool topic")
      # pp resource.logical_id # uncomment to debug
      # pp resource.properties # uncomment to debug
      expect(resource.logical_id).to eq "SharedResourceMySnsTopic"
      properties = resource.properties
      expect(properties['DisplayName']).to eq "cool topic"
    end
  end
end
