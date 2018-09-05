describe Jets::Cfn::Builders::ApiDeploymentBuilder do
  let(:builder) do
    Jets::Cfn::Builders::ApiDeploymentBuilder.new({})
  end

  describe "ApiDeploymentBuilder" do
    it "builds a child stack the deployment" do
      builder.compose
      # puts builder.text # uncomment to see template text

      resources = builder.template["Resources"]
      resource_types = resources.values.map { |i| i["Type"] }
      expect(resource_types).to include("AWS::ApiGateway::Deployment")

      expect(builder.template_path).to eq "#{Jets.build_root}/templates/demo-test-api-deployment.yml"
    end
  end
end
