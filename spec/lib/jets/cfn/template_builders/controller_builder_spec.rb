require "spec_helper"

describe Jets::Cfn::TemplateBuilders::ControllerBuilder do
  let(:builder) do
    Jets::Cfn::TemplateBuilders::ControllerBuilder.new(app_class)
  end

  context "PostsController" do
    let(:app_class) { PostsController }
    describe "compose" do
      it "builds a child stack with controller resources" do
        builder.compose
        # puts builder.text # uncomment to see template text

        resources = builder.template["Resources"]
        resource_types = resources.values.map { |i| i["Type"] }
        expect(resource_types).to include("AWS::Lambda::Function")
        expect(resource_types).to include("AWS::ApiGateway::Method")
        expect(resource_types).to include("AWS::Lambda::Permission")

        expect(builder.template_path).to eq "#{Jets.build_root}/templates/demo-test-posts_controller.yml"
      end
    end
  end

  context "StoresController" do
    let(:app_class) { StoresController }
    describe "show function properties" do
      it "overrides global properties with function properties" do
        builder.compose
        # puts builder.text # uncomment to see template text
        resources = builder.template["Resources"]
        properties = resources["StoresControllerShowLambdaFunction"]["Properties"]

        expect(properties["MemorySize"]).to eq 1024
        # should not pascalize the keys under Variables section
        expect(properties["Environment"]["Variables"]).to eq(
          "JETS_ENV" => "test",
          "my_test" => "data",
          "key1" => "value1",
          "key2" => "value2",
        )
      end
    end

    describe "index function properties" do
      it "overrides global properties with function properties" do
        builder.compose
        # puts builder.text # uncomment to see template text
        resources = builder.template["Resources"]
        properties = resources["StoresControllerIndexLambdaFunction"]["Properties"]

        expect(properties["MemorySize"]).to eq 1000
        # should not pascalize the keys under Variables section
        expect(properties["DeadLetterConfig"]).to eq "arn"
      end
    end

    describe "new function properties" do
      it "overrides global properties with function properties" do
        builder.compose
        # puts builder.text # uncomment to see template text
        resources = builder.template["Resources"]
        properties = resources["StoresControllerNewLambdaFunction"]["Properties"]

        expect(properties["MemorySize"]).to eq 768
      end
    end
  end
end
