require "spec_helper"

describe Jets::Lambda::FunctionConstructor do
  let(:constructor) { Jets::Lambda::FunctionConstructor.new(code_path) }
  let(:code_path) { "spec/fixtures/apps/demo/app/functions/hello_function.rb" }

  let(:event) { {"key1" => "value1", "key2" => "value2", "key3" => "value3"} }

  it "build" do
    HelloFunction = constructor.build
    hello_function = HelloFunction.new
    result = hello_function.lambda_handler(event, {})
    expect(result).to eq "value1"
  end
end
