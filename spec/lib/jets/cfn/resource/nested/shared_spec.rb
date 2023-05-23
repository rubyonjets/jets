describe Jets::Cfn::Resource::Nested::Shared do
  let(:resource) do
    path = "/tmp/jets/demo/templates/shared-custom.yml"
    Jets::Cfn::Resource::Nested::Shared.new(s3_bucket: "s3-bucket", path: path)
  end

  describe "resource" do
    it "contains child stack info" do
      allow(Jets).to receive(:s3_bucket).and_return("s3-bucket")
      expect(resource.logical_id).to eq "Custom"
      properties = resource.properties
      expect(properties[:TemplateURL]).to eq "https://s3.amazonaws.com/s3-bucket/jets/cfn-templates/shas//shared-custom.yml"
    end
  end
end
