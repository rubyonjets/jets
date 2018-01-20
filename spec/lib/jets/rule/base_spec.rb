require "spec_helper"

describe Jets::Rule::Base do
  let(:null) { double(:null).as_null_object }

  # by the time the class is finished loading into memory the properties have
  # been load loaded so we can use them later to configure the lambda functions
  context GameRule do
    it "tasks" do
      tasks = GameRule.all_tasks.keys
      expect(tasks).to eq [:protect]

      protect_task = GameRule.all_tasks[:protect]
      expect(protect_task).to be_a(Jets::Rule::Task)
    end

    it "tasks contains flatten Array structure" do
      tasks = GameRule.tasks
      expect(tasks.first).to be_a(Jets::Rule::Task)

      task_names = tasks.map(&:name)
      expect(task_names).to eq(GameRule.all_tasks.keys)
    end
  end
end
