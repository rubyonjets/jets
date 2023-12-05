describe Jets::Lambda::Definition do
  context "PostsController" do
    let(:definition) do
      Jets::Lambda::Definition.new("PostsController", :index)
    end

    it "type" do
      expect(definition.type).to eq "controller"
    end
  end

  context "HardJob" do
    let(:definition) do
      Jets::Lambda::Definition.new("HardJob", :dig)
    end

    it "type" do
      expect(definition.type).to eq "job"
    end
  end

  context "HelloWorld which is anonyomous class" do
    let(:definition) do
      # functions are anonymoust classes which have a class_name of "".
      # We will fix the class name later when in FunctionConstructor.
      # This is tested in function_constructor_spec.rb.
      Jets::Lambda::Definition.new("", :world)
    end

    it "type" do
      expect(definition.type).to be nil
    end
  end
end
