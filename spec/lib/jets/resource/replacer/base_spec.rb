describe Jets::Resource::Replacer::Base do
  let(:replacer) { Jets::Resource::Replacer::Base.new(task) }
  let(:task) do
    task = double(:task).as_null_object
    allow(task).to receive(:class_name).and_return("SecurityJob")
    allow(task).to receive(:meth).and_return(:disable_unused_credentials)
    task
  end
  let(:attributes) do
    {
      k: "k-value",
      a: {
        b: "b-value"
      }
    }
  end

  context "raw cloudformation definition" do
    it "replace_placeholders" do
      allow(replacer).to receive(:replace_value).and_return("test") # stub out for testing
      result = replacer.replace_placeholders(attributes, {}) # replacements dont matter due to stub
      # pp result
      expect(result).to eq(a: {b: "test"}, k: "test")
    end
  end
end