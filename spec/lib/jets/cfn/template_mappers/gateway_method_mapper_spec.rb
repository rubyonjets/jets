describe Jets::Cfn::TemplateMappers::GatewayMethodMapper do
  let(:map) do
    Jets::Cfn::TemplateMappers::GatewayMethodMapper.new(route)
  end

  describe "GatewayMethodMapper" do
    context "posts" do
      let(:route) { Jets::Route.new(path: "posts", method: :get, to: "posts#index") }
      it "posts contains info for CloudFormation API Gateway Resources" do
        expect(map.logical_id).to eq "PostsGetApiMethod"
        expect(map.gateway_resource_logical_id).to eq "PostsApiResource"
        expect(map.lambda_function_logical_id).to eq "PostsControllerIndexLambdaFunction"
      end

    end

    context("*catchall") do
      let(:route) { Jets::Route.new(path: "*catchall", method: :get, to: "public_files#show") }
      it "uses valid characters for logical id" do
        expect(map.logical_id).to eq "CatchallGetApiMethod"
      end
    end


    context "posts/:id/edit" do
      let(:route) { Jets::Route.new(path: "posts/:id/edit", method: :get, to: "posts#edit") }
      it "posts/:id/edit contains info for CloudFormation API Gateway Resources" do
        expect(map.logical_id).to eq "PostsIdEditGetApiMethod"
        expect(map.gateway_resource_logical_id).to eq "PostsIdEditApiResource"
        expect(map.lambda_function_logical_id).to eq "PostsControllerEditLambdaFunction"
      end
    end

    context "admin/pages/:id/edit" do
      let(:route) { Jets::Route.new(path: "admin/pages/:id/edit", method: :get, to: "admin/pages#edit") }
      it "admin/pages/:id/edit contains info for CloudFormation API Gateway Resources" do
        expect(map.logical_id).to eq "AdminPagesIdEditGetApiMethod"
        expect(map.gateway_resource_logical_id).to eq "AdminPagesIdEditApiResource"
        expect(map.lambda_function_logical_id).to eq "AdminPagesControllerEditLambdaFunction"
      end
    end

    context "homepage - top most level root url" do
      let(:route) { Jets::Route.new(path: "", method: :get, to: "home#show") }

      it "contains info for CloudFormation API Gateway Resources" do
        expect(map.logical_id).to eq "RootPathHomepageGetApiMethod"
        expect(map.gateway_resource_logical_id).to eq "RootResourceId"
        expect(map.lambda_function_logical_id).to eq "HomeControllerShowLambdaFunction"
      end
    end
  end
end
