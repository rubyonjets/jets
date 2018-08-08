describe Jets::Cfn::TemplateMappers::ApiGatewayMapper do
  let(:map) do
    Jets::Cfn::TemplateMappers::ApiGatewayMapper.new("#{Jets.build_root}/templates/#{Jets.config.project_namespace}-api-gateway.yml", "s3-bucket")
  end

  describe "map" do
    it "contains info for app stack resource" do
      expect(map.path).to eq "#{Jets.build_root}/templates/#{Jets.config.project_namespace}-api-gateway.yml"
      expect(map.logical_id).to eq "ApiGateway"
      expect(map.template_url).to eq "https://s3.amazonaws.com/s3-bucket/jets/cfn-templates/#{Jets.config.project_namespace}-api-gateway.yml"
      expect(map.parameters).to be_a(Hash)
    end
  end
end
