describe Jets::Resource::ApiGateway::Resource do
  let(:resource) { Jets::Resource::ApiGateway::Resource.new(path) }

  context "posts/:id/edit" do
    let(:path) { "posts/:id/edit" }
    it "resource" do
      expect(resource.logical_id).to eq "PostsIdEditApiResource"
      properties = resource.properties
      # pp properties # uncomment to debug
      expect(properties["ParentId"]).to eq "!Ref PostsIdApiResource"
      expect(properties["PathPart"]).to eq "edit"
    end
  end

  context("*catchall") do
    let(:path) { "*catchall" }
    it "uses valid characters for logical id" do
      expect(resource.logical_id).to eq "CatchallApiResource"
      properties = resource.properties
      expect(properties["PathPart"]).to eq "{catchall+}"
    end
  end

  context("show path with path_part that has the capture") do
    let(:path) { "posts/:id" }
    it "contains info for CloudFormation API Gateway Resources" do
      expect(resource.logical_id).to eq "PostsIdApiResource"
      properties = resource.properties
      expect(properties["PathPart"]).to eq "{id}"
      expect(properties["ParentId"]).to eq "!Ref PostsApiResource"
    end
  end

  context("posts index is a root level path") do
    let(:path) { "posts" }
    it "contains info for CloudFormation API Gateway Resources" do
      expect(resource.logical_id).to eq "PostsApiResource"
      properties = resource.properties
      expect(properties["PathPart"]).to eq "posts"
      expect(properties["ParentId"]).to eq "!Ref RootResourceId"
    end
  end

  # So a resource for the root path is never really created but we have this
  # spec because the definitions get initialized right away and we dont
  # want initialization to crash.
  # Controllers use a an '' path route to add a parameter:
  #   scoped_routes.each do |route|
  #     resource = Jets::Resource::ApiGateway::Resource.new(route.path)
  #     add_parameter(resource.logical_id, Description: resource.desc)
  #   end
  context("top most root level path") do
    let(:path) { "" }
    it "contains info for CloudFormation API Gateway Resources" do
      expect(resource.logical_id).to eq "RootResourceId"

      # puts "resource.logical_id #{resource.logical_id.inspect}"
      # For the top most root level route, methods part_part and parent_id
      # never caled.
      # puts "properties["PathPart" #{properties["PathPart".inspect}"
      # puts "properties["ParentId" #{properties["ParentId".inspect}"
    end
  end

  context("url with dash") do
    let(:path) { "url-with-dash" }
    it "contains info for CloudFormation API Gateway Resources" do
      expect(resource.logical_id).to eq "UrlWithDashApiResource"
      properties = resource.properties
      expect(properties["PathPart"]).to eq "url-with-dash"
      expect(properties["ParentId"]).to eq "!Ref RootResourceId"
    end
  end

  context("url.with.dot") do
    let(:path) { "url.with.dot" }
    it "contains info for CloudFormation API Gateway Resources" do
      expect(resource.logical_id).to eq "UrlWithDotApiResource"
      properties = resource.properties
      expect(properties["PathPart"]).to eq "url.with.dot"
      expect(properties["ParentId"]).to eq "!Ref RootResourceId"
    end
  end

end

