require "spec_helper"

describe Jets::Cfn::TemplateMappers::ConfigRuleMapper do
  let(:map) do
    Jets::Cfn::TemplateMappers::ConfigRuleMapper.new(task)
  end
  let(:task) do
    Jets::Rule::Task.new("SecurityRule", :protect)
  end

  describe "maps" do
    it "contains info for CloudFormation template" do
      expect(map.logical_id).to eq "SecurityRuleProtectConfigRule"
      expect(map.lambda_function_logical_id).to eq "SecurityRuleProtectLambdaFunction"

      expect(map.permission_logical_id).to eq "SecurityRuleProtectConfigRulePermission"

      expect(map.send(:full_task_name)).to eq "SecurityRuleProtect"
    end
  end
end
