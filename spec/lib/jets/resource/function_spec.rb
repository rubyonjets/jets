describe Jets::Resource::Function do
  let(:resource) { Jets::Resource::Function.new(task) }
  let(:task) do
    PostsController.all_tasks[:index]
  end

  context "function timeout 18" do
    it "uses function properties" do
      expect(resource.logical_id).to eq "PostsGetApiMethod"
      properties = resource.properties
      pp properties # uncomment to debug
      expect(properties["RestApiId"]).to eq "!Ref RestApi"
      expect(properties["ResourceId"]).to eq "!Ref PostsApiResource"
      expect(properties["HttpMethod"]).to eq "GET"
    end
  end
end

