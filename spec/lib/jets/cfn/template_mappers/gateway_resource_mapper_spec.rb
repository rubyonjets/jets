require "spec_helper"

describe Jets::Cfn::TemplateMappers::GatewayResourceMapper do
  let(:map) do
    Jets::Cfn::TemplateMappers::GatewayResourceMapper.new(route)
  end
  let(:route) do
    # only info that matters for spec is path
    Jets::Route.new(path: path, method: :get, to: "posts#index")
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

    context("*catchall") do
      let(:path) { "*catchall" }
      it "uses valid characters for logical id" do
        expect(map.logical_id).to eq "CatchallApiGatewayResource"
        expect(map.path_part).to eq "{catchall+}"
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
        expect(map.logical_id).to eq "PostsApiGatewayResource"
        expect(map.path_part).to eq "posts"
        expect(map.parent_id).to eq "!GetAtt RestApi.RootResourceId"
      end
    end

    context("top most root level path") do
      let(:path) { "" }
      it "contains info for CloudFormation API Gateway Resources" do
        puts "map.path #{map.path.inspect}"
        puts "map.logical_id #{map.logical_id.inspect}"
        # For the top most root level route, methods part_part and parent_id
        # never caled.
        # puts "map.path_part #{map.path_part.inspect}"
        # puts "map.parent_id #{map.parent_id.inspect}"
      end
    end
  end
end
