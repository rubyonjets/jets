require "spec_helper"

describe Jets::Cfn::Mappers::GatewayResourceMapper do
  let(:map) do
    Jets::Cfn::Mappers::GatewayResourceMapper.new(path)
  end

  describe "GatewayResourceMapper" do
    context("edit path") do
      let(:path) { "posts/:id/edit" }
      it "contains info for CloudFormation API Gateway Resources" do
        expect(map.logical_id).to eq "ApiGatewayResourcePostsIdEdit"
        expect(map.cors_logical_id).to eq "ApiGatewayResourcePostsIdEditCors"
        expect(map.path_part).to eq "edit"
        expect(map.parent_id).to eq "!Ref ApiGatewayResourcePostsId"
      end
    end

    context("show path with path_part that has the capture") do
      let(:path) { "posts/:id" }
      it "contains info for CloudFormation API Gateway Resources" do
        expect(map.logical_id).to eq "ApiGatewayResourcePostsId"
        expect(map.path_part).to eq "{id}"
        expect(map.parent_id).to eq "!Ref ApiGatewayResourcePosts"
      end
    end

    context("posts index is a root level path") do
      let(:path) { "posts" }
      it "contains info for CloudFormation API Gateway Resources" do
        expect(map.parent_id).to eq "!GetAtt ApiGatewayRestApi.RootResourceId"
      end
    end
  end
end
