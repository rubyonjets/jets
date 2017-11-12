require "spec_helper"

describe Jets::Cfn::TemplateBuilders::ControllerBuilder do
  let(:builder) do
    Jets::Cfn::TemplateBuilders::ControllerBuilder.new(app_class)
  end
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

      expect(builder.template_path).to eq "#{Jets.build_root}/templates/demo-test-2-posts_controller.yml"
    end
  end
end
