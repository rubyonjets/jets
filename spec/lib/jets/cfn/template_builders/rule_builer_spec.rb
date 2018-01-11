require "spec_helper"

describe Jets::Cfn::TemplateBuilders::RuleBuilder do
  let(:builder) do
    Jets::Cfn::TemplateBuilders::RuleBuilder.new(SecurityRule)
  end

  describe "compose" do
    it "builds a child stack with the scheduled events" do
      builder.compose
      # puts builder.text # uncomment to see template text

      resources = builder.template["Resources"]
      expect(resources).to include("SecurityRuleProtectLambdaFunction")
      expect(resources).to include("SecurityRuleProtectEventsRulePermission")
      expect(resources).to include("SecurityRuleProtectScheduledEvent")

      expect(builder.template_path).to eq "#{Jets.build_root}/templates/demo-test-security_rule.yml"
    end
  end
end
