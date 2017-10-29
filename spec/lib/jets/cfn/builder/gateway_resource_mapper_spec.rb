require_relative "../../../../spec_helper"

describe Jets::Cfn::Builder::GatewayResourceMapper do
  let(:map) do
    Jets::Cfn::Builder::GatewayResourceMapper.new(path)
  end

  describe "GatewayResourceMapper" do
    context("edit path") do
      let(:path) { "posts/:id/edit" }
      it "contains info for CloudFormation API Gateway Resources" do
        expect(map.gateway_resource_logical_id).to eq "ApiGatewayResourcePostsIdEdit"
        expect(map.path_part).to eq "edit"
      end
    end

    context("show path with path_part that has the capture") do
      let(:path) { "posts/:id" }
      it "contains info for CloudFormation API Gateway Resources" do
        expect(map.gateway_resource_logical_id).to eq "ApiGatewayResourcePostsId"
        expect(map.path_part).to eq "{id}"
      end
    end
  end
end
