require_relative "../../../../spec_helper"

describe Jets::Cfn::Builder::GatewayMapper do
  let(:map) do
    Jets::Cfn::Builder::GatewayMapper.new(route)
  end

  describe "GatewayMapper" do
    let(:route) { Jets::Build::Route.new(path: "posts", method: :get, to: "posts#index") }
    it "contains info for CloudFormation API Gateway Resources" do
      expect(map.gateway_resource_logical_id).to eq "ApiGatewayResourcePostsController"
      expect(map.gateway_method_logical_id).to eq "ApiGatewayMethodPostsControllerIndex"
      expect(map.lambda_function_logical_id).to eq "PostsControllerIndexLambdaFunction"
    end
  end
end
