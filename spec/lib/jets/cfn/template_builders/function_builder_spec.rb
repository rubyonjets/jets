require "spec_helper"

describe Jets::Cfn::TemplateBuilders::FunctionBuilder do
  let(:builder) do
    Jets::Cfn::TemplateBuilders::FunctionBuilder.new(klass)
  end
  let(:klass) do
    Jets::Klass.from_path("app/functions/hello.rb")
  end

  describe "compose" do
    it "builds a child stack with the scheduled events" do
      builder.compose
      # puts builder.text # uncomment to see template text

      resources = builder.template["Resources"]
      expect(resources).to include("HelloWorldLambdaFunction")

      expect(builder.template_path).to eq "#{Jets.build_root}/templates/demo-test-hello_function.yml"
    end
  end
end
