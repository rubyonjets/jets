require_relative "../../../../spec_helper"

describe Jets::Cfn::Builder::LambdaFunctionMapper do
  let(:map) do
    Jets::Cfn::Builder::LambdaFunctionMapper.new("PostsController", :index)
  end

  describe "LambdaFunctionMapper" do
    it "contains info for CloudFormation Lambda Function Resources" do
      expect(map.lambda_function_logical_id).to eq "PostsControllerIndexLambdaFunction"
    end
  end
end
