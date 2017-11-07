require "spec_helper"

describe Jets::Cfn::TemplateBuilders::ApiGatewayDeploymentBuilder do
  let(:builder) do
    Jets::Cfn::TemplateBuilders::ApiGatewayDeploymentBuilder.new({})
  end

  describe "ApiGatewayDeploymentBuilder" do
    it "builds a child stack the deployment" do
      builder.compose
      # puts builder.text # uncomment to see template text

      resources = builder.template["Resources"]
      resource_types = resources.values.map { |i| i["Type"] }
      expect(resource_types).to include("AWS::ApiGateway::Deployment")

      expect(builder.template_path).to eq "#{Jets.tmp_build}/templates/demo-test-2-api-gateway-deployment.yml"
    end
  end
end
