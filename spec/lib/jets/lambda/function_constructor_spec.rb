require "spec_helper"

describe Jets::Lambda::FunctionConstructor do
  let(:constructor) { Jets::Lambda::FunctionConstructor.new(code_path) }
  let(:code_path) { "app/functions/hello.rb" }

  let(:event) { {"key1" => "value1", "key2" => "value2", "key3" => "value3"} }

  context "with _function" do
    it "build returns hello function that has world handler method to call" do
      WhateverFunction = constructor.build
      whatever_function = WhateverFunction.new
      result = whatever_function.world(event, {})
      expect(result).to eq 'hello world: "value1"'
    end
  end

  context "without _function" do
    it "build calls adjust_tasks and adds class_name and type" do
      Hello = constructor.build
      task = Hello.tasks.first
      expect(task.class_name).to eq "Hello"
      expect(task.type).to eq "function"
    end
  end
end
