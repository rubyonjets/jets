describe Jets::Resource::ChildStack::Shared do
  let(:resource) do
    path = "/tmp/jets/demo/templates/demo-test-shared-custom.yml"
    Jets::Resource::ChildStack::Shared.new("s3-bucket", path: path)
  end

  describe "resource" do
    it "contains child stack info" do
      expect(resource.logical_id).to eq "Custom"
      properties = resource.properties
      expect(properties["TemplateURL"]).to eq "https://s3.amazonaws.com/s3-bucket/jets/cfn-templates/#{Jets.config.project_namespace}-shared-custom.yml"
    end
  end
end
