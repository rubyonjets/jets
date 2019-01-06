describe Jets::Rule::Base do
  let(:null) { double(:null).as_null_object }

  # by the time the class is finished loading into memory the properties have
  # been load loaded so we can use them later to configure the lambda functions
  context GameRule do
    it "tasks" do
      tasks = GameRule.all_public_tasks.keys
      expect(tasks).to eq [:protect]

      protect_task = GameRule.all_public_tasks[:protect]
      expect(protect_task).to be_a(Jets::Lambda::Task)
    end

    it "tasks contains flatten Array structure" do
      tasks = GameRule.tasks
      expect(tasks.first).to be_a(Jets::Lambda::Task)

      task_names = tasks.map(&:name)
      expect(task_names).to eq(GameRule.all_public_tasks.keys)
    end
  end
end

class Example1Rule < Jets::Rule::Base
end

class Example2Rule < Example1Rule
  rule_namespace false
end

class Example3Rule < Example2Rule
end

describe "example rules" do
  it "rule_namespace" do
    expect(Example1Rule.rule_namespace).to be nil
    expect(Example2Rule.rule_namespace).to be false
    expect(Example3Rule.rule_namespace).to be nil
  end

  let(:rule) { Jets::Resource::Config::ConfigRule.new(klass.to_s, "meth") }
  context "inherited rule namespace" do
    let(:klass) { Example3Rule }
    it "config_rule_name" do
      expect(rule.config_rule_name).to eq "example3-meth"
    end
  end

  context "false namespace" do
    let(:klass) { Example2Rule }
    it "config_rule_name" do
      expect(rule.config_rule_name).to eq "example2-meth"
    end
  end

  context "nil namespace" do
    let(:klass) { Example1Rule }
    it "config_rule_name" do
      expect(rule.config_rule_name).to eq "demo-test-example1-meth"
    end
  end
end