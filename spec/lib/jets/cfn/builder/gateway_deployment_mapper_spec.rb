require_relative "../../../../spec_helper"

describe Jets::Cfn::Builder::GatewayDeploymentMapper do
  let(:map) do
    Jets::Cfn::Builder::GatewayDeploymentMapper.new
  end

  describe "GatewayDeploymentMapper" do
    it "contains info for CloudFormation API Gateway Resources" do
      expect(map.gateway_deployment_logical_id).to include("ApiGatewayDeployment")
    end
  end
end
