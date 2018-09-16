class ExampleStack < Jets::Stack
  ruby_function(:hello)
  python_function(:kevin)
end

describe "Stack builder" do
  let(:function) { Jets::Stack::Function.new(template) }

  context "ruby function" do
    let(:template) { ExampleStack.new.resources.map(&:template).first }
    it "lang is ruby" do
      expect(function.lang).to eq :ruby
    end
  end

  context "python function" do
    let(:template) { ExampleStack.new.resources.map(&:template).last }
    it "lang is python" do
      expect(function.lang).to eq :python
    end
  end
end
