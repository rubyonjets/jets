describe Jets::Cfn::Resource::Lambda::GemLayer do
  let(:resource) { Jets::Cfn::Resource::Lambda::GemLayer.new }

  context "gems layer version" do
    it "builds template" do
      expect(resource.logical_id).to eq "GemLayer"
      properties = resource.properties
      # puts YAML.dump(properties) # uncomment to debug
      expect(properties[:LayerName]).to eq "test-demo-gems"
    end
  end
end

