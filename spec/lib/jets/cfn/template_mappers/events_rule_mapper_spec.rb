require "spec_helper"

describe Jets::Cfn::TemplateMappers::EventsRuleMapper do
  let(:mapper) do
    Jets::Cfn::TemplateMappers::EventsRuleMapper.new(task)
  end
  let(:task) do
    Jets::Job::Task.new(:dig,
      rate: "1 minute",
      class_name: "HardJob",
    )
  end

  describe "maps" do
    it "contains info for CloudFormation template" do
      expect(mapper.logical_id).to eq "HardJobDigScheduledEvent"
      expect(mapper.lambda_function_logical_id).to eq "HardJobDigLambdaFunction"
      expect(mapper.rule_target_id).to eq "HardJobDigRuleTarget"

      expect(mapper.permission_logical_id).to eq "HardJobDigPermissionEventsRule"

      expect(mapper.send(:full_task_name)).to eq "HardJobDig"
    end
  end
end
