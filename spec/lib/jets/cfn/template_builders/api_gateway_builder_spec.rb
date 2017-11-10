require "spec_helper"

describe Jets::Cfn::TemplateBuilders::ApiGatewayBuilder do
  let(:builder) do
    Jets::Cfn::TemplateBuilders::ApiGatewayBuilder.new({})
  end

  describe "ApiGatewayBuilder" do
    it "builds a child stack with shared api gateway resources" do
      builder.compose
      # puts builder.text # uncomment to see template text

      resources = builder.template["Resources"]
      expect(resources).to include("ApiGatewayRestApi")
      # Probably at least one route or AWS::ApiGateway::Resource is created
      resource_types = resources.values.map { |i| i["Type"] }
      expect(resource_types).to include("AWS::ApiGateway::Resource")

      expect(builder.template_path).to eq "#{Jets.tmpdir}/templates/demo-test-2-api-gateway.yml"
    end
  end
end
