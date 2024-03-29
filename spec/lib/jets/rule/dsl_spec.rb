# Example with the full config_rule syntax
class FullPropertiesRule < Jets::Rule::Base
  resource(config_rule_definition(:protect))
  def protect
    puts "protect"
  end
end

class PrettyPropertiesRule < Jets::Rule::Base
  scope "AWS::EC2::SecurityGroup"
  def protect
    puts "protect"
  end
end

describe Jets::Rule::Dsl do
  context "FullPropertiesRule" do
    let(:rule) { FullPropertiesRule.new({}, nil, "protect") }

    it "associated_resources" do
      protect_task = FullPropertiesRule.all_public_definitions[:protect]
      expect(protect_task).to be_a(Jets::Lambda::Definition)
      resources = protect_task.associated_resources
      associated_resource = resources.first
      expect(associated_resource.logical_id).to eq "{namespace}ConfigRule".to_sym
      attributes = associated_resource.attributes
      props = attributes[:Properties]
      expect(props[:ConfigRuleName]).to eq "demo-test-full-properties-protect"
    end
  end

  context "PrettyPropertiesRule" do
    let(:rule) { PrettyPropertiesRule.new({}, nil, "protect") }

    it "scope expands to full ComplianceResourceTypes with AWS::EC2::SecurityGroup" do
      protect_task = PrettyPropertiesRule.all_public_definitions[:protect]
      expect(protect_task).to be_a(Jets::Lambda::Definition)
      resources = protect_task.associated_resources
      associated_resource = resources.first
      attributes = associated_resource.attributes
      props = attributes[:Properties]
      expect(props[:Scope][:ComplianceResourceTypes]).to eq(["AWS::EC2::SecurityGroup"])
    end
  end
end
