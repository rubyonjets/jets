describe Jets::Rule::Task do

  it "conventional_config_rule_name" do
    task = Jets::Rule::Task.new(GameRule, "protect")
    expect(task.config_rule_name).to eq "game-protect"
  end
end
