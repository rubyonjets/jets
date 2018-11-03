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
      protect_task = FullPropertiesRule.all_public_tasks[:protect]
      expect(protect_task).to be_a(Jets::Lambda::Task)
      resources = protect_task.associated_resources
      associated_resource = resources.first
      attributes = associated_resource.values.first
      props = attributes[:properties]
      expect(props[:config_rule_name]).to eq "{config_rule_name}" # will eventually be replaced
    end
  end

  context "PrettyPropertiesRule" do
    let(:rule) { PrettyPropertiesRule.new({}, nil, "protect") }

    it "scope expands to full ComplianceResourceTypes with AWS::EC2::SecurityGroup" do
      protect_task = PrettyPropertiesRule.all_public_tasks[:protect]
      expect(protect_task).to be_a(Jets::Lambda::Task)
      resources = protect_task.associated_resources
      associated_resource = resources.first
      attributes = associated_resource.values.first
      props = attributes[:properties]
      expect(props[:scope][:compliance_resource_types]).to eq(["AWS::EC2::SecurityGroup"])
    end
  end
end
