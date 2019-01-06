class TestPropertiesController < ApplicationController
  properties(
    dead_letter_config: "arn", timeout: 20, role: "myrole", memory_size: 1000
  )
  def index
  end
end

describe Jets::Lambda::Dsl do
  context "TestPropertiesController" do
    let(:controller) { TestPropertiesController.new({}, nil, "index") }

    it "tasks" do
      index_task = TestPropertiesController.all_public_tasks[:index]
      expect(index_task).to be_a(Jets::Lambda::Task)
      expect(index_task.properties).to eq(
        dead_letter_config: "arn", timeout: 20, role: "myrole", memory_size: 1000
      )
    end
  end

  context "StoresController" do
    let(:controller) { StoresController.new({}, nil, "new") }

    it "tasks" do
      tasks = StoresController.all_public_tasks.keys
      expect(tasks).to eq [:index, :new, :show]

      index_task = StoresController.all_public_tasks[:index]
      expect(index_task).to be_a(Jets::Lambda::Task)
    end

    it "timeout" do
      task = StoresController.all_public_tasks[:new]
      expect(task.properties).to eq(timeout: 35)
    end

    it "environment" do
      task = StoresController.all_public_tasks[:show]
      expect(task.properties[:environment]).to eq({
        variables: {
          key1: "value1",
          key2: "value2",
        }})
    end

    it "memory_size" do
      task = StoresController.all_public_tasks[:show]
      expect(task.properties[:memory_size]).to eq 1024
    end
  end

  context "Admin::StoresController" do
    let(:controller) { Admin::StoresController.new({}, nil, "new") }

    it "tasks should include tasks from parent class" do
      tasks = Admin::StoresController.all_public_tasks.keys
      expect(tasks).to eq [:index, :new, :show]
    end
  end

  context "App extension iot" do
    it "creates custom resource" do
      task = TemperatureJob.tasks.first
      # pp task # uncomment to see and debug
      logical_id = task.associated_resources.first.logical_id
      expect(logical_id).to eq "room_topic_rule"
    end
  end

  context "Class with inherited tasks" do
    it "contains tasks from parent classes" do
      tasks = ChildPostsController.all_public_tasks
      meths = tasks.keys
      expect(meths).to eq [:index, :new, :show, :create, :edit, :update, :delete, :foobar]
      expect(tasks[:index].class_name).to eq "ChildPostsController"
      expect(tasks[:foobar].class_name).to eq "ChildPostsController"
      expect(tasks[:show].class_name).to eq "ChildPostsController"
    end
  end
end
