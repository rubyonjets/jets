describe Jets::Cfn::TemplateMappers::ApiGatewayDeploymentMapper do
  let(:map) do
    Jets::Cfn::TemplateMappers::ApiGatewayDeploymentMapper.new("#{Jets.build_root}/templates/#{Jets.config.project_namespace}-api-gateway-deployment.yml", "s3-bucket")
  end

  describe "map" do
    it "contains info for app stack resource" do
      expect(map.path).to eq "#{Jets.build_root}/templates/#{Jets.config.project_namespace}-api-gateway-deployment.yml"
      expect(map.logical_id).to match(/ApiGatewayDeployment(\d+)/)
      expect(map.template_url).to eq "https://s3.amazonaws.com/s3-bucket/jets/cfn-templates/#{Jets.config.project_namespace}-api-gateway-deployment.yml"
      expect(map.parameters).to be_a(Hash)
    end
  end
end
