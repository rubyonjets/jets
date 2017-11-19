require "spec_helper"

describe Jets::Lambda::Dsl do
  context "StoresController" do
    let(:controller) { StoresController.new({}, nil, "new") }

    it "tasks" do
      tasks = StoresController.tasks.keys
      expect(tasks).to eq [:index, :new]

      index_task = StoresController.tasks[:index]
      expect(index_task).to be_a(Jets::Lambda::Task)
      expect(index_task.properties).to eq(
        dead_letter_config: "arn", timeout: 20, role: "myrole", memory_size: 1000
      )

      new_task = StoresController.tasks[:new]
      expect(new_task).to be_a(Jets::Lambda::Task)
      expect(new_task.properties).to eq(timeout: 35)
    end
  end

  context "Admin::StoresController" do
    let(:controller) { Admin::StoresController.new({}, nil, "new") }

    it "tasks should not include tasks from parent class" do
      tasks = Admin::StoresController.tasks.keys
      # pp tasks
      expect(tasks).to eq []
    end
  end
end
