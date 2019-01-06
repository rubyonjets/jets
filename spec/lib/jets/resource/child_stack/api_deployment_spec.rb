describe Jets::Resource::ChildStack::ApiDeployment do
  let(:resource) do
    Jets::Resource::ChildStack::ApiDeployment.new("s3-bucket")
  end

  describe "resource" do
    it "contains child stack info" do
      expect(resource.logical_id).to match(/ApiDeployment(\d+)/)
      properties = resource.properties
      expect(properties["TemplateURL"]).to eq "https://s3.amazonaws.com/s3-bucket/jets/cfn-templates/#{Jets.config.project_namespace}-api-deployment.yml"
    end
  end
end
