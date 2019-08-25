describe Jets::Cfn::Builders::ApiResourcesBuilder do
  let(:builder) do
    Jets::Cfn::Builders::ApiResourcesBuilder.new({}, paths, page)
  end
  let(:paths) { Jets::Router.all_paths }
  let(:page)  { 1 }

  describe "ApiResourcesBuilder" do
    it "builds a child stack with shared api gateway resources" do
      builder.compose
      # puts builder.text # uncomment to see template text

      template = builder.template
      resources = template["Resources"]
      # Probably at least one route or AWS::ApiGateway::Resource is created
      resource_types = resources.values.map { |i| i["Type"] }
      expect(resource_types).to include("AWS::ApiGateway::Resource")

      # Sanity check. Pretty much all AWS::ApiGateway::Resource resources will have an output
      outputs = template["Outputs"]
      expect(outputs).not_to be_empty

      expect(builder.template_path).to eq "#{Jets.build_root}/templates/demo-test-api-resources-1.yml"
    end
  end
end
