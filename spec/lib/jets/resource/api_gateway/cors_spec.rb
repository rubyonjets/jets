describe Jets::Resource::ApiGateway::Cors do
  let(:resource) { Jets::Resource::ApiGateway::Cors.new(route) }
  let(:route) do
    Jets::Route.new(path: "posts", method: :get, to: "posts#index")
  end

  context "cors" do
    it "resource" do
      expect(resource.logical_id).to eq "PostsCorsApiMethod"
      properties = resource.properties
      # pp properties # uncomment to debug
      expect(properties["RestApiId"]).to eq "!Ref RestApi"
      expect(properties["ResourceId"]).to eq "!Ref PostsApiResource"
      expect(properties["HttpMethod"]).to eq "OPTIONS"
    end

    it 'defaults to no authorization' do
      expect(resource.properties["AuthorizationType"]).to eq 'NONE'
    end
  end

  context "authorization" do
    let(:route) do
      Jets::Route.new(path: "posts", method: :get, to: "posts#index", authorization_type: 'AWS_IAM')
    end
    it "can specify an authorization type" do
      expect(resource.properties["AuthorizationType"]).to eq 'AWS_IAM'
    end
  end
end

