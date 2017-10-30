require_relative "../../../../spec_helper"

describe Jets::Cfn::Builder::ApiGatewayDeploymentMapper do
  let(:app) do
    Jets::Cfn::Builder::ApiGatewayDeploymentMapper.new("/tmp/jets_build/templates/#{Jets::Config.project_namespace}-api-gateway-deployment.yml", "s3-bucket")
  end

  describe "ApiGatewayDeploymentMapper" do
    it "contains info for app stack resource" do
      expect(app.path).to eq "/tmp/jets_build/templates/#{Jets::Config.project_namespace}-api-gateway-deployment.yml"
      expect(app.logical_id).to eq "ApiGatewayDeployment"
      expect(app.template_url).to eq "https://s3.amazonaws.com/s3-bucket/jets/cfn-templates/#{Jets::Config.project_namespace}-api-gateway-deployment.yml"
      expect(app.parameters).to be_a(Hash)
    end
  end
end
