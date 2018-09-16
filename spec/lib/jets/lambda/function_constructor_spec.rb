describe Jets::Lambda::FunctionConstructor do
  let(:constructor) { Jets::Lambda::FunctionConstructor.new(code_path) }

  context("app function") do
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

  context("shared function") do
    let(:code_path) { "app/shared/functions/whatever.rb" }
    let(:event) { {"key1" => "value1", "key2" => "value2", "key3" => "value3"} }
    context "assigned to constant" do
      it "build calls adjust_tasks and adds class_name and type" do
        Whatever = constructor.build
        task = Whatever.tasks.first
        expect(task.class_name).to eq "Whatever"
        expect(task.type).to eq "function"

        result = Whatever.process(event, {}, :handle)
        expect(result).to eq 'hello world: "value1"'
      end
    end
  end
end
