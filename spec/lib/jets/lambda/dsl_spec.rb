require "spec_helper"

describe Jets::Lambda::Dsl do
  context "StoresController" do
    let(:controller) { StoresController.new({}, nil, "new") }

    it "functions" do
      functions = StoresController.functions.keys
      expect(functions).to eq [:index, :new]

      index_function = StoresController.functions[:index]
      expect(index_function).to be_a(Jets::Lambda::RegisteredFunction)
      expect(index_function.properties).to eq(
        dead_letter_config: "arn", timeout: 20, role: "myrole", memory_size: 1000
      )

      new_function = StoresController.functions[:new]
      expect(new_function).to be_a(Jets::Lambda::RegisteredFunction)
      expect(new_function.properties).to eq(timeout: 35)
    end
  end

  context "Admin::StoresController" do
    let(:controller) { Admin::StoresController.new({}, nil, "new") }

    it "functions should not include functions from parent class" do
      functions = Admin::StoresController.functions.keys
      # pp functions
      expect(functions).to eq []
    end
  end
end
