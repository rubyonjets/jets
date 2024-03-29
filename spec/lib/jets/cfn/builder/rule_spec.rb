describe Jets::Cfn::Builder::Rule do
  let(:builder) do
    Jets::Cfn::Builder::Rule.new(GameRule)
  end

  describe "compose" do
    it "builds a child stack with the scheduled events" do
      builder.compose
      # puts builder.text # uncomment to see template text

      resources = builder.template["Resources"]
      expect(resources).to include("GameRuleProtectLambdaFunction")
      expect(resources).to include("GameRuleProtectPermission")
      expect(resources).to include("GameRuleProtectConfigRule")

      expect(builder.template_path).to eq "#{Jets.build_root}/templates/app-game_rule.yml"
    end
  end
end
