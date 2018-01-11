require "spec_helper"

describe Jets::Rule::Task do

  it "conventional_config_rule_name" do
    task = Jets::Rule::Task.new(GameRule, "protect")
    expect(task.config_rule_name).to eq "game-rule-protect"
  end
end
