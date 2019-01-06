class FunctionExampleStack < Jets::Stack
  ruby_function(:hello)
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
      expect(function.meth).to eq "handle"
    end
  end

  context "python function" do
    let(:template) { FunctionExampleStack.new.resources.map(&:template).last }
    it "lang is python" do
      expect(function.lang).to eq :python
    end
  end
end
