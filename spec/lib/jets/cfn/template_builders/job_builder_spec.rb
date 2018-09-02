describe Jets::Cfn::TemplateBuilders::JobBuilder do
  let(:builder) do
    Jets::Cfn::TemplateBuilders::JobBuilder.new(HardJob)
  end

  describe "compose" do
    it "builds a child stack with the scheduled events" do
      builder.compose
      # puts builder.text # uncomment to see template text

      resources = builder.template["Resources"]
      expect(resources).to include("HardJobDigLambdaFunction")
      expect(resources).to include("HardJobDigPermission")
      expect(resources).to include("HardJobLiftEventsRule")

      expect(builder.template_path).to eq "#{Jets.build_root}/templates/demo-test-hard_job.yml"
    end
  end
end
