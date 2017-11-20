require "spec_helper"

describe Jets::Cfn::TemplateMappers::EventsRuleMapper do
  let(:map) do
    Jets::Cfn::TemplateMappers::EventsRuleMapper.new(task)
  end
  let(:task) do
    Jets::Job::Task.new("HardJob", :dig,
      rate: "1 minute")
  end

  describe "maps" do
    it "contains info for CloudFormation template" do
      expect(map.logical_id).to eq "HardJobDigScheduledEvent"
      expect(map.lambda_function_logical_id).to eq "HardJobDigLambdaFunction"
      expect(map.rule_target_id).to eq "HardJobDigRuleTarget"

      expect(map.permission_logical_id).to eq "HardJobDigPermissionEventsRule"

      expect(map.send(:full_task_name)).to eq "HardJobDig"
    end
  end
end
