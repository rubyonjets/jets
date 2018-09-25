describe Jets::Resource::ChildStack::Shared do
  let(:resource) do
    path = "/tmp/jets/config/templates/config-dev-shared-custom.yml"
    Jets::Resource::ChildStack::Shared.new("s3-bucket", path: path)
  end

  describe "resource" do
    it "contains child stack info" do
      expect(resource.logical_id).to eq "Alarm"
      properties = resource.properties
      expect(properties["TemplateUrl"]).to eq "https://s3.amazonaws.com/s3-bucket/jets/cfn-templates/#{Jets.config.project_namespace}-shared-alarm.yml"
    end
  end
end
