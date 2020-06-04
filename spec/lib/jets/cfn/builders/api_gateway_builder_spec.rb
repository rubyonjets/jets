describe Jets::Cfn::Builders::ApiGatewayBuilder do

  let(:builder) do
    Jets::Cfn::Builders::ApiGatewayBuilder.new({})
  end

  describe "ApiGatewayBuilder" do
    it "builds a child stack with api gateway rest api" do
      builder.compose
      # puts builder.text # uncomment to see template text

      resources = builder.template["Resources"]

      expect(resources).to include("RestApi")

      expect(builder.template_path).to eq "#{Jets.build_root}/templates/demo-test-api-gateway.yml"
    end

    it "must create the DomainName and DnsRecord" do
      allow(Jets.config.domain).to receive(:name).and_return("demo-test.example.com")
      allow(Jets.config.domain).to receive(:hosted_zone_name).and_return("example.com")
      
      builder.compose

      resources = builder.template["Resources"]

      expect(resources).to include("DomainName")
      expect(resources).to include("DnsRecord")
      expect(resources).to include("RestApi")

      expect(builder.template_path).to eq "#{Jets.build_root}/templates/demo-test-api-gateway.yml"
    end

    it "must exclude DomainName and DnsRecord" do
      allow(Jets.config.domain).to receive(:name).and_return("124demo-test.example.com")
      allow(Jets.config.domain).to receive(:hosted_zone_name).and_return("example.com")
      
      allow(builder.apigateway).to receive(:get_domain_name).and_return({})
      allow(builder.cfn).to receive(:describe_stack_resource).with(hash_including(:logical_resource_id => "ApiGateway")).and_return(nil)
      allow(builder.cfn).to receive(:describe_stack_resource).with(hash_including(:logical_resource_id => "DomainName")).and_throw(:this_symbol)
      allow(builder.cfn).to receive(:describe_stack_resource).with(hash_including(:logical_resource_id => "DnsRecord")).and_throw(:this_symbol)
      
      
      builder.compose

      resources = builder.template["Resources"]
      
      expect(resources).to_not include("DomainName")
      expect(resources).to_not include("DnsRecord")
      expect(resources).to include("RestApi")

      expect(builder.template_path).to eq "#{Jets.build_root}/templates/demo-test-api-gateway.yml"
    end

    it "should not exclude DomainName and DnsRecord" do
      allow(Jets.config.domain).to receive(:name).and_return("124demo-test.example.com")
      allow(Jets.config.domain).to receive(:hosted_zone_name).and_return("example.com")
      
      allow(builder.apigateway).to receive(:get_domain_name).and_return({})
      allow(builder.cfn).to receive(:describe_stack_resource).with(hash_including(:logical_resource_id => "ApiGateway")).and_return(nil)
      allow(builder.cfn).to receive(:describe_stack_resource).with(hash_including(:logical_resource_id => "DomainName")).and_return({})
      allow(builder.cfn).to receive(:describe_stack_resource).with(hash_including(:logical_resource_id => "DnsRecord")).and_return({})
      
      
      builder.compose

      resources = builder.template["Resources"]
      
      expect(resources).to include("DomainName")
      expect(resources).to include("DnsRecord")
      expect(resources).to include("RestApi")

      expect(builder.template_path).to eq "#{Jets.build_root}/templates/demo-test-api-gateway.yml"
    end
  end

end
