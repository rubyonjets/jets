describe Jets::Resource::Replacer do
  let(:replacer) { Jets::Resource::Replacer.new(replacements) }
  let(:attributes) do
    {
      k: "{namespace}-value",
      a: {
        b: "{namespace}-value"
      }
    }
  end
  let(:replacements) { { namespace: "FooBar" } }

  context "raw cloudformation definition" do
    it "replace_placeholders" do
      result = replacer.replace_placeholders(attributes)
      # pp result
      expect(result).to eq(a: {b: "FooBar-value"}, k: "FooBar-value")
    end
  end
end