require "spec_helper"

describe Jets::Cfn::Builder::LambdaFunctionMapper do
  let(:map) do
    Jets::Cfn::Builder::LambdaFunctionMapper.new("PostsController", :index)
  end

  describe "LambdaFunctionMapper" do
    it "contains info for CloudFormation Lambda Function Resources" do
      expect(map.lambda_function_logical_id).to eq "PostsControllerIndexLambdaFunction"
      expect(map.controller_action).to eq "PostsControllerIndex"
      expect(map.function_name).to eq "#{Jets::Config.project_namespace}-posts-controller-index"
      expect(map.handler).to eq "handlers/controllers/posts.index"
      expect(map.code_s3_key).to include("jets/code")
    end
  end
end
