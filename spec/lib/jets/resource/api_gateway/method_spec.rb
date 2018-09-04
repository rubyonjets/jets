describe Jets::Resource::ApiGateway::Method do
  let(:resource) { Jets::Resource::ApiGateway::Method.new(route) }

  context "post#index" do
    let(:route) do
      Jets::Route.new(path: "posts", method: :get, to: "posts#index")
    end
    it "resource" do
      expect(resource.logical_id).to eq "PostsGetApiMethod"
      properties = resource.properties
      # pp properties # uncomment to debug
      expect(properties["RestApiId"]).to eq "!Ref RestApi"
      expect(properties["ResourceId"]).to eq "!Ref PostsApiResource"
      expect(properties["HttpMethod"]).to eq "GET"
    end
  end
end

