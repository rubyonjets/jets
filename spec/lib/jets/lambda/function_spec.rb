require "spec_helper"

class TestHelloFunction < Jets::Lambda::Function
  # first method is automatically used as the handler
  def handler(event, context={})
    event["key1"]
  end

  # other methods to help
  def another_function
  end

  def some_other_helper
  end
end

describe Jets::Lambda::Function do
  context TestHelloFunction do
    it "first method used as the handler" do
      task = TestHelloFunction.handler_task
      expect(task.meth).to eq :handler
    end
  end

  context "created function" do
    let(:hello_function) { TestHelloFunction.new }

    it "handler function returns the right result" do
      result = hello_function.handler("key1" => "value1")
      expect(result).to eq "value1"
    end
  end
end
