require "spec_helper"

describe Jets::Cfn::TemplateBuilders::JobBuilder do
  let(:builder) do
    Jets::Cfn::TemplateBuilders::JobBuilder.new(app_class)
  end
  let(:app_class) { HardJob }

  describe "compose" do
    it "builds a child stack with the scheduled events" do
      builder.compose
      # puts builder.text # uncomment to see template text

      resources = builder.template["Resources"]
      expect(resources).to include("HardJobDigLambdaFunction")
      expect(resources).to include("HardJobDigScheduledEvent")
      expect(resources).to include("HardJobDigPermissionEventsRule")

      expect(builder.template_path).to eq "#{Jets.tmpdir}/templates/demo-test-2-hard_job.yml"
    end
  end
end
