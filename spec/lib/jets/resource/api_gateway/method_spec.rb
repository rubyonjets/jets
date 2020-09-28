describe Jets::Resource::ApiGateway::Method do
  let(:resource) { Jets::Resource::ApiGateway::Method.new(route) }

  context "post#index" do
    let(:route) do
      Jets::Router::Route.new(path: "posts", method: :get, to: "posts#index")
    end

    it "resource" do
      expect(resource.logical_id).to eq "PostsIndexGetApiMethod"
      properties = resource.properties
      # pp properties # uncomment to debug
      expect(properties["RestApiId"]).to eq "!Ref RestApi"
      expect(properties["ResourceId"]).to eq "!Ref PostsApiResource"
      expect(properties["HttpMethod"]).to eq "GET"
    end

    it 'defaults to no authorization' do
      expect(resource.properties["AuthorizationType"]).to eq 'NONE'
    end

    it 'defaults to no api_key_required' do
      expect(resource.properties["ApiKeyRequired"]).to eq 'false'
    end
  end

  context "long route" do
    let(:route) do
      Jets::Router::Route.new(path: "posts/:post_id/comments/:comment_id/images/:images/source_urls/:source_urls", method: :get, to: "posts#index")
    end

    it "long route" do
      expect(resource.logical_id).to eq "PostsPostIdCommentsCommentIdImagesImagesSourceUrlsSourceeb106e"
      expect(resource.logical_id.size).to eq 62
    end

    it "resource" do
      expect(resource.logical_id).to eq "PostsPostIdCommentsCommentIdImagesImagesSourceUrlsSourceeb106e"
      properties = resource.properties
      # pp properties # uncomment to debug
      expect(properties["RestApiId"]).to eq "!Ref RestApi"
      expect(properties["ResourceId"]).to eq "!Ref PostsPostIdCommentsCommentIdImagesImagesSourcaa1e8bApiResource"
      expect(properties["HttpMethod"]).to eq "GET"
    end
  end

  context "route contains dot" do
    let(:route) do
      Jets::Router::Route.new(path: "v1.2/posts/:post_id/", method: :get, to: "posts#index")
    end

    it "route contains dot" do
      expect(resource.logical_id).to eq "V12PostsPostIdIndexGetApiMethod"
      expect(resource.logical_id.size).to eq 31
    end

    it "resource" do
      expect(resource.logical_id).to eq "V12PostsPostIdIndexGetApiMethod"
      properties = resource.properties
      # pp properties # uncomment to debug
      expect(properties["RestApiId"]).to eq "!Ref RestApi"
      expect(properties["ResourceId"]).to eq "!Ref V12PostsPostIdApiResource"
      expect(properties["HttpMethod"]).to eq "GET"
    end
  end

  context "authorization" do
    let(:route) do
      Jets::Router::Route.new(path: "posts", method: :get, to: "posts#index", authorization_type: 'AWS_IAM')
    end
    it "can specify an authorization type" do
      expect(resource.properties["AuthorizationType"]).to eq 'AWS_IAM'
    end
  end

  context "api key" do
    let(:route) do
      Jets::Router::Route.new(path: "posts", method: :get, to: "posts#index", api_key_required: true)
    end

    it "can specify an api_key_required" do
      expect(resource.properties["ApiKeyRequired"]).to eq 'true'
    end
  end

  context "authorization scopes on rotes" do
    let(:route) do
      Jets::Router::Route.new(path: "posts", method: :get, to: "posts#index", authorization_scopes: %w[create delete])
    end
    it "can specify an authorization scopes" do
      expect(resource.properties["AuthorizationScopes"]).to eq ["create", "delete"]
    end
  end

  context "authorization scopes on controller" do
    let(:route) do
      Jets::Router::Route.new(path: "toys", method: :get, to: "toys#index")
    end
    it "can specify an authorization scopes" do
      expect(resource.properties["AuthorizationScopes"]).to eq ["create", "delete"]
    end
  end
end
