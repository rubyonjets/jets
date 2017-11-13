require "spec_helper"

describe Jets::Cfn::TemplateMappers::GatewayMethodMapper do
  let(:map) do
    Jets::Cfn::TemplateMappers::GatewayMethodMapper.new(route)
  end

  describe "GatewayMethodMapper" do
    context "posts" do
      let(:route) { Jets::Route.new(path: "posts", method: :get, to: "posts#index") }
      it "posts contains info for CloudFormation API Gateway Resources" do
        expect(map.logical_id).to eq "PostsGetApiGatewayMethod"
        expect(map.gateway_resource_logical_id).to eq "PostsApiGatewayResource"
        expect(map.lambda_function_logical_id).to eq "PostsControllerIndexLambdaFunction"
      end
    end

    context "posts/:id/edit" do
      let(:route) { Jets::Route.new(path: "posts/:id/edit", method: :get, to: "posts#edit") }
      it "posts/:id/edit contains info for CloudFormation API Gateway Resources" do
        expect(map.logical_id).to eq "PostsIdEditGetApiGatewayMethod"
        expect(map.gateway_resource_logical_id).to eq "PostsIdEditApiGatewayResource"
        expect(map.lambda_function_logical_id).to eq "PostsControllerEditLambdaFunction"
      end
    end

    context "admin/pages/:id/edit" do
      let(:route) { Jets::Route.new(path: "admin/pages/:id/edit", method: :get, to: "admin/pages#edit") }
      it "admin/pages/:id/edit contains info for CloudFormation API Gateway Resources" do
        expect(map.logical_id).to eq "AdminPagesIdEditGetApiGatewayMethod"
        expect(map.gateway_resource_logical_id).to eq "AdminPagesIdEditApiGatewayResource"
        expect(map.lambda_function_logical_id).to eq "AdminPagesControllerEditLambdaFunction"
      end
    end
  end
end
