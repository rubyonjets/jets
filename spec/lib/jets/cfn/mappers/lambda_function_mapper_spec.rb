require "spec_helper"

describe Jets::Cfn::Mappers::LambdaFunctionMapper do
  context "controller" do
    let(:map) do
      Jets::Cfn::Mappers::LambdaFunctionMapper.new("PostsController", :index)
    end

    describe "ControllerFunctionMapper" do
      it "contains info for CloudFormation Controller Function Resources" do
        expect(map.lambda_function_logical_id).to eq "PostsControllerIndexLambdaFunction"
        expect(map.class_action).to eq "PostsControllerIndex"
        expect(map.function_name).to eq "#{Jets::Config.project_namespace}-posts-controller-index"
        expect(map.handler).to eq "handlers/controllers/posts.index"
        expect(map.code_s3_key).to include("jets/code")
      end
    end
  end

  context("job") do
    let(:map) do
      Jets::Cfn::Mappers::LambdaFunctionMapper.new("SleepJob", :perform)
    end

    describe "JobFunctionMapper" do
      it "contains info for CloudFormation Job Function Resources" do
        expect(map.lambda_function_logical_id).to eq "SleepJobPerformLambdaFunction"
        expect(map.class_action).to eq "SleepJobPerform"
        expect(map.function_name).to eq "#{Jets::Config.project_namespace}-sleep-job-perform"
        expect(map.handler).to eq "handlers/jobs/sleep.perform"
        expect(map.code_s3_key).to include("jets/code")
      end
    end
  end
end
