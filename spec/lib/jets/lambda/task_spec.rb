require "spec_helper"

describe Jets::Lambda::Task do
  context "PostsController" do
    let(:task) do
      Jets::Lambda::Task.new("PostsController", :index)
    end

    it "type" do
      expect(task.type).to eq "controller"
    end
  end

  context "HardJob" do
    let(:task) do
      Jets::Lambda::Task.new("HardJob", :dig)
    end

    it "type" do
      expect(task.type).to eq "job"
    end
  end

  context "HelloWorld which is anonyomous class" do
    let(:task) do
      # functions are anonymoust classes which have a class_name of "".
      # We will fix the class name later when in FunctionConstructor.
      # This is tested in function_constructor_spec.rb.
      Jets::Lambda::Task.new("", :world)
    end

    it "type" do
      expect(task.type).to be nil
    end
  end
end
