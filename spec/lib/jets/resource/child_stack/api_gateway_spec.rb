describe Jets::Resource::ChildStack::ApiGateway do
  let(:resource) do
    Jets::Resource::ChildStack::ApiGateway.new("s3-bucket")
  end

  describe "resource" do
    it "contains child stack info" do
      expect(resource.logical_id).to eq "ApiGateway"
      properties = resource.properties
      expect(properties["TemplateUrl"]).to eq "https://s3.amazonaws.com/s3-bucket/jets/cfn-templates/#{Jets.config.project_namespace}-api-gateway.yml"
    end
  end
end
