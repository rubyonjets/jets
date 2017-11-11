require "spec_helper"

describe Jets::Cfn::TemplateMappers::GatewayResourceMapper do
  let(:map) do
    Jets::Cfn::TemplateMappers::GatewayResourceMapper.new(path)
  end

  describe "GatewayResourceMapper" do
    context("edit path") do
      let(:path) { "posts/:id/edit" }
      it "contains info for CloudFormation API Gateway Resources" do
        expect(map.logical_id).to eq "PostsIdEditApiGatewayResource"
        expect(map.cors_logical_id).to eq "PostsIdEditCorsApiGatewayResource"
        expect(map.path_part).to eq "edit"
        expect(map.parent_id).to eq "!Ref PostsIdApiGatewayResource"
      end
    end

    context("show path with path_part that has the capture") do
      let(:path) { "posts/:id" }
      it "contains info for CloudFormation API Gateway Resources" do
        expect(map.logical_id).to eq "PostsIdApiGatewayResource"
        expect(map.path_part).to eq "{id}"
        expect(map.parent_id).to eq "!Ref PostsApiGatewayResource"
      end
    end

    context("posts index is a root level path") do
      let(:path) { "posts" }
      it "contains info for CloudFormation API Gateway Resources" do
        expect(map.parent_id).to eq "!GetAtt RestApi.RootResourceId"
      end
    end
  end
end
