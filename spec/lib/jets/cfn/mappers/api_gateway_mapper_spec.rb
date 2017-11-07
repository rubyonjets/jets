require "spec_helper"

describe Jets::Cfn::Mappers::ApiGatewayMapper do
  let(:app) do
    Jets::Cfn::Mappers::ApiGatewayMapper.new("#{Jets.tmp_build}/templates/#{Jets.config.project_namespace}-api-gateway.yml", "s3-bucket")
  end

  describe "ApiGatewayMapper" do
    it "contains info for app stack resource" do
      expect(app.path).to eq "#{Jets.tmp_build}/templates/#{Jets.config.project_namespace}-api-gateway.yml"
      expect(app.logical_id).to eq "ApiGateway"
      expect(app.template_url).to eq "https://s3.amazonaws.com/s3-bucket/jets/cfn-templates/#{Jets.config.project_namespace}-api-gateway.yml"
      expect(app.parameters).to be_a(Hash)
    end
  end
end
