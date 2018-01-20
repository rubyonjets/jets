require "spec_helper"

describe Jets::Cfn::TemplateBuilders::RuleBuilder do
  let(:builder) do
    Jets::Cfn::TemplateBuilders::RuleBuilder.new(GameRule)
  end

  describe "compose" do
    it "builds a child stack with the scheduled events" do
      builder.compose
      puts builder.text # uncomment to see template text

      resources = builder.template["Resources"]
      expect(resources).to include("GameRuleProtectLambdaFunction")
      expect(resources).to include("GameRuleProtectConfigRulePermission")
      expect(resources).to include("GameRuleProtectConfigRule")

      expect(builder.template_path).to eq "#{Jets.build_root}/templates/demo-test-game_rule.yml"
    end
  end
end
