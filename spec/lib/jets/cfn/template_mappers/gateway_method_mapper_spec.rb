require "spec_helper"

describe Jets::Cfn::TemplateMappers::GatewayMethodMapper do
  let(:map) do
    Jets::Cfn::TemplateMappers::GatewayMethodMapper.new(route)
  end

  describe "GatewayMethodMapper" do
    context "posts" do
      let(:route) { Jets::Route.new(path: "posts", method: :get, to: "posts#index") }
      it "posts contains info for CloudFormation API Gateway Resources" do
        expect(map.logical_id).to eq "ApiGatewayMethodPostsGet"
        expect(map.gateway_resource_logical_id).to eq "ApiGatewayResourcePosts"
        expect(map.lambda_function_logical_id).to eq "PostsControllerIndexLambdaFunction"
      end
    end

    context "posts/:id/edit" do
      let(:route) { Jets::Route.new(path: "posts/:id/edit", method: :get, to: "posts#edit") }
      it "posts/:id/edit contains info for CloudFormation API Gateway Resources" do
        expect(map.logical_id).to eq "ApiGatewayMethodPostsIdEditGet"
        expect(map.gateway_resource_logical_id).to eq "ApiGatewayResourcePostsIdEdit"
        expect(map.lambda_function_logical_id).to eq "PostsControllerEditLambdaFunction"
      end
    end
  end
end
