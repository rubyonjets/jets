describe Jets::Cfn::Builder::Job do
  require 'active_support/testing/stream'
  include ActiveSupport::Testing::Stream

  let(:builder) do
    Jets::Cfn::Builder::Job.new(HardJob)
  end

  describe "compose" do
    it "builds a child stack with the scheduled events" do
      builder.compose
      # puts builder.text # uncomment to see template text

      resources = builder.template["Resources"]
      expect(resources).to include("HardJobDigLambdaFunction")
      expect(resources).to include("HardJobLiftEventsRule")

      expect(builder.template_path).to eq "#{Jets.build_root}/templates/app-hard_job.yml"
    end
  end

  describe "class_iam_policy" do
    it 'does not warn' do
      output = capture(:stdout) do
        class IamPolicyJob < ApplicationJob
          class_iam_policy 'lambda:InvokeFunction'
        end
      end

      expect(output).not_to include("WARNING: class_iam_policy")
    end
  end
end
