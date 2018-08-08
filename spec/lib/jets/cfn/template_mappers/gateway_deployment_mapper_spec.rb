describe Jets::Cfn::TemplateMappers::ApiGatewayDeploymentMapper do
  let(:map) do
    Jets::Cfn::TemplateMappers::ApiGatewayDeploymentMapper.new("path", "s3-bucket")
  end

  describe "ApiGatewayDeploymentMapper" do
    it "contains info for CloudFormation API Gateway Resources" do
      # Example map.logical_id: ApiGatewayDeployment20171107083325
      expect(map.logical_id).to include("ApiGatewayDeployment")
    end
  end
end
