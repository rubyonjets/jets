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

    it "definitions" do
      index_definition = TestPropertiesController.all_public_definitions[:index]
      expect(index_definition).to be_a(Jets::Lambda::Definition)
      expect(index_definition.properties).to eq(
        {:DeadLetterConfig=>"arn", :MemorySize=>1000, :Role=>"myrole", :Timeout=>20}
      )
    end
  end

  context "StoresController" do
    let(:controller) { StoresController.new({}, nil, "new") }

    it "definitions" do
      definitions = StoresController.all_public_definitions.keys
      expect(definitions).to eq [:index, :new, :show]

      index_definition = StoresController.all_public_definitions[:index]
      expect(index_definition).to be_a(Jets::Lambda::Definition)
    end

    it "timeout" do
      definition = StoresController.all_public_definitions[:new]
      expect(definition.properties).to eq(Timeout: 35)
    end

    it "environment" do
      definition = StoresController.all_public_definitions[:show]
      expect(definition.properties[:Environment]).to eq({
        Variables: {
          key1: "value1",
          key2: "value2",
        }})
    end

    it "memory_size" do
      definition = StoresController.all_public_definitions[:show]
      expect(definition.properties[:MemorySize]).to eq 1024
    end
  end

  context "Admin::StoresController" do
    let(:controller) { Admin::StoresController.new({}, nil, "new") }

    it "definitions should include definitions from parent class" do
      definitions = Admin::StoresController.all_public_definitions.keys
      expect(definitions).to eq [:index, :new, :show]
    end
  end

  context "App extension iot" do
    it "creates custom resource" do
      definition = TemperatureJob.definitions.first
      # pp definition # uncomment to see and debug
      logical_id = definition.associated_resources.first.logical_id
      expect(logical_id).to eq "room_topic_rule"
    end
  end

  context "Class with inherited definitions" do
    it "contains definitions from parent classes" do
      definitions = ChildPostsController.all_public_definitions
      meths = definitions.keys
      expect(meths).to eq [:index, :new, :show, :create, :edit, :update, :delete, :foobar]
      expect(definitions[:index].class_name).to eq "ChildPostsController"
      expect(definitions[:foobar].class_name).to eq "ChildPostsController"
      expect(definitions[:show].class_name).to eq "ChildPostsController"
    end
  end
end
