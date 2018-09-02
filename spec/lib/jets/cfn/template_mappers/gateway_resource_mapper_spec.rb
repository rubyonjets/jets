describe Jets::Cfn::TemplateMappers::GatewayResourceMapper do
  let(:map) do
    Jets::Cfn::TemplateMappers::GatewayResourceMapper.new(path)
  end

  describe "GatewayResourceMapper" do
    context("edit path") do
      let(:path) { "posts/:id/edit" }
      it "contains info for CloudFormation API Gateway Resources" do
        expect(map.logical_id).to eq "PostsIdEditApiResource"
        expect(map.cors_logical_id).to eq "PostsIdEditCorsApiResource"
        expect(map.path_part).to eq "edit"
        expect(map.parent_id).to eq "!Ref PostsIdApiResource"
      end
    end

    context("*catchall") do
      let(:path) { "*catchall" }
      it "uses valid characters for logical id" do
        expect(map.logical_id).to eq "CatchallApiResource"
        expect(map.path_part).to eq "{catchall+}"
      end
    end

    context("show path with path_part that has the capture") do
      let(:path) { "posts/:id" }
      it "contains info for CloudFormation API Gateway Resources" do
        expect(map.logical_id).to eq "PostsIdApiResource"
        expect(map.path_part).to eq "{id}"
        expect(map.parent_id).to eq "!Ref PostsApiResource"
      end
    end

    context("posts index is a root level path") do
      let(:path) { "posts" }
      it "contains info for CloudFormation API Gateway Resources" do
        expect(map.logical_id).to eq "PostsApiResource"
        expect(map.path_part).to eq "posts"
        expect(map.parent_id).to eq "!GetAtt RestApi.HomepageApiResource"
      end
    end

    context("top most root level path") do
      let(:path) { "" }
      it "contains info for CloudFormation API Gateway Resources" do
        # puts "map.path #{map.path.inspect}"
        # puts "map.logical_id #{map.logical_id.inspect}"
        # For the top most root level route, methods part_part and parent_id
        # never caled.
        # puts "map.path_part #{map.path_part.inspect}"
        # puts "map.parent_id #{map.parent_id.inspect}"
      end
    end
  end
end
