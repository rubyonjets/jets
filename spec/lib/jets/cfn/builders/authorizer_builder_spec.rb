describe Jets::Cfn::Builders::AuthorizerBuilder do
  let(:builder) do
    Jets::Cfn::Builders::AuthorizerBuilder.new(path)
  end

  context "MainAuthorizer" do
    let(:path) { "app/authorizers/main_authorizer.rb" }
    describe "compose" do
      it "builds a child stack with controller resources" do
        builder.compose
        # puts builder.text # uncomment to see template text

        resources = builder.template["Resources"]
        resource_types = resources.values.map { |i| i["Type"] }
        expect(resource_types).to include("AWS::Lambda::Function")
        expect(resource_types).to include("AWS::Lambda::Permission")
        expect(resource_types).to include("AWS::ApiGateway::Authorizer")

        outputs = builder.template["Outputs"] # ProtectAuthorizer, LockAuthorizer, CognitoAuthorizer
        expect(outputs).not_to be_empty

        expect(builder.template_path).to eq "#{Jets.build_root}/templates/demo-test-authorizers-main_authorizer.yml"
      end
    end
  end
end
