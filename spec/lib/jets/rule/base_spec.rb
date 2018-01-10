require "spec_helper"

describe Jets::Rule::Base do
  let(:null) { double(:null).as_null_object }

  # by the time the class is finished loading into memory the properties have
  # been load loaded so we can use them later to configure the lambda functions
  context SecurityRule do
    it "tasks" do
      tasks = SecurityRule.all_tasks.keys
      expect(tasks).to eq [:protect]

      protect_task = SecurityRule.all_tasks[:protect]
      expect(protect_task).to be_a(Jets::Rule::Task)
      expect(protect_task.properties).to eq({:scope=>{"ComplianceResourceTypes"=>["AWS::EC2::SecurityGroup"]}})
    end

    it "tasks contains flatten Array structure" do
      tasks = SecurityRule.tasks
      expect(tasks.first).to be_a(Jets::Rule::Task)

      task_names = tasks.map(&:name)
      expect(task_names).to eq(SecurityRule.all_tasks.keys)
    end
  end
end
