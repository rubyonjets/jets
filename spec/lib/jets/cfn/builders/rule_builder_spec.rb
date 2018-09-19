describe Jets::Cfn::Builders::RuleBuilder do
  let(:builder) do
    Jets::Cfn::Builders::RuleBuilder.new(GameRule)
  end

  describe "compose" do
    it "builds a child stack with the scheduled events" do
      builder.compose
      # puts builder.text # uncomment to see template text

      resources = builder.template["Resources"]
      expect(resources).to include("ProtectLambdaFunction")
      expect(resources).to include("ProtectPermission")
      expect(resources).to include("ProtectConfigRule")

      expect(builder.template_path).to eq "#{Jets.build_root}/templates/demo-test-app-game_rule.yml"
    end
  end
end
