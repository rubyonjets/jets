require "spec_helper"

describe Jets::Cfn::TemplateBuilders::FunctionPropertiesBuilder do
  let(:builder) do
    Jets::Cfn::TemplateBuilders::FunctionPropertiesBuilder.new(task)
  end

  context "HardJob#dig" do
    let(:task) do
      Jets::Job::Task.new("HardJob", :dig, rate: "1 minute")
    end

    describe "properties" do
      it "contain the lambda function properties" do
        props = builder.properties
        # pp props
        expect(props["Timeout"]).to eq 10
      end
    end
  end

  context "StoresController#index" do
    let(:task) do
      StoresController.all_tasks[:index]
    end

    describe "properties" do
      it "contain the lambda function properties" do
        props = builder.properties
        # pp props
        # testing properties(...)
        expect(props["MemorySize"]).to eq 1000
        expect(props["Role"]).to eq "myrole"
        expect(props["Timeout"]).to eq 20
      end
    end
  end

  context "StoresController#new" do
    let(:task) do
      StoresController.all_tasks[:new]
    end

    describe "properties" do
      it "contain the lambda function properties" do
        props = builder.properties
        # pp props
        # testing class_properties(...)
        expect(props["MemorySize"]).to eq 768
      end
    end
  end
end
