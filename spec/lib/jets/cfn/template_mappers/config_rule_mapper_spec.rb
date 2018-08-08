describe Jets::Cfn::TemplateMappers::ConfigRuleMapper do
  let(:map) do
    Jets::Cfn::TemplateMappers::ConfigRuleMapper.new(task)
  end
  let(:task) do
    Jets::Rule::Task.new("GameRule", :protect)
  end

  describe "maps" do
    it "contains info for CloudFormation template" do
      expect(map.logical_id).to eq "GameRuleProtectConfigRule"
      expect(map.lambda_function_logical_id).to eq "GameRuleProtectLambdaFunction"

      expect(map.permission_logical_id).to eq "GameRuleProtectConfigRulePermission"

      expect(map.send(:full_task_name)).to eq "GameRuleProtect"
    end
  end
end
