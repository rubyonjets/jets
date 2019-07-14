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
      expect(properties["ResourceId"]).to eq "!Ref PostsPostIdCommentsCommentIdImagesImagesSourceUrlsSource9fe958"
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
end

