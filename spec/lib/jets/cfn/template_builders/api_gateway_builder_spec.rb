require "spec_helper"

describe Jets::Cfn::TemplateBuilders::ApiGatewayBuilder do
  let(:builder) do
    Jets::Cfn::TemplateBuilders::ApiGatewayBuilder.new({})
  end

  describe "ApiGatewayBuilder" do
    it "builds a child stack with the shared api gateway resources" do
      expect(builder.template_path).to eq "#{Jets.tmp_build}/templates/demo-test-2-api-gateway.yml"
    end
  end
end
