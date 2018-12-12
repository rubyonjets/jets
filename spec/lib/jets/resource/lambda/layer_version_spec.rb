describe Jets::Resource::Lambda::LayerVersion do
  let(:resource) { Jets::Resource::Lambda::LayerVersion.new }

  context "gems layer version" do
    it "builds template" do
      expect(resource.logical_id).to eq "GemsLayerVersion"
      properties = resource.properties
      # puts YAML.dump(properties) # uncomment to debug
      expect(properties["CompatibleRuntimes"]).to eq ["ruby2.5"]
      expect(properties["LayerName"]).to eq "jets-ruby-gems"
    end
  end
end

