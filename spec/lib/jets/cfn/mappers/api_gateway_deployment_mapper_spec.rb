require "spec_helper"

describe Jets::Cfn::Mappers::ApiGatewayDeploymentMapper do
  let(:app) do
    Jets::Cfn::Mappers::ApiGatewayDeploymentMapper.new("/tmp/jets_build/templates/#{Jets.config.project_namespace}-api-gateway-deployment.yml", "s3-bucket")
  end

  describe "ApiGatewayDeploymentMapper" do
    it "contains info for app stack resource" do
      expect(app.path).to eq "/tmp/jets_build/templates/#{Jets.config.project_namespace}-api-gateway-deployment.yml"
      expect(app.logical_id).to match(/ApiGatewayDeployment(\d+)/)
      expect(app.template_url).to eq "https://s3.amazonaws.com/s3-bucket/jets/cfn-templates/#{Jets.config.project_namespace}-api-gateway-deployment.yml"
      expect(app.parameters).to be_a(Hash)
    end
  end
end
