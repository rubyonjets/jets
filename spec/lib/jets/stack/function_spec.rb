class FunctionExampleStack < Jets::Stack
  ruby_function(:hello)
  ruby_function("admin/send_message")
  python_function(:kevin)
end

describe "Stack builder" do
  let(:function) { Jets::Stack::Function.new(template) }

  context "ruby function" do
    let(:template) { FunctionExampleStack.new.resources.map(&:template).first }
    it "lang is ruby" do
      expect(function.lang).to eq :ruby
    end

    it "meth" do
      expect(function.meth).to eq "lambda_handler"
    end
  end

  context "function with namespace" do
    let(:template) { FunctionExampleStack.new.resources.map(&:template)[1] }
    it "lang is ruby" do
      props = template["AdminSendMessage"]["Properties"]
      expect(props["FunctionName"]).to eq "demo-test-function_example_stack-admin-send_message"
      expect(props["Handler"]).to eq "handlers/shared/functions/admin/send_message.lambda_handler"
      expect(function.lang).to eq :ruby
    end
  end

  context "python function" do
    let(:template) { FunctionExampleStack.new.resources.map(&:template).last }
    it "lang is python" do
      expect(function.lang).to eq :python
    end
  end

end
