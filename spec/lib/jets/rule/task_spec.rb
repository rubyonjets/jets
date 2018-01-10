require "spec_helper"

describe Jets::Rule::Task do

  it "conventional_config_rule_name" do
    task = Jets::Rule::Task.new(SecurityRule, "protect")
    expect(task.config_rule_name).to eq "security-rule-protect"
  end
end
