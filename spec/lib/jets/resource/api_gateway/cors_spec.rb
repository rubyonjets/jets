describe Jets::Resource::ApiGateway::Cors do
  let(:resource) { Jets::Resource::ApiGateway::Cors.new(route) }

  context "cors" do
    let(:route) do
      Jets::Route.new(path: "posts", method: :get, to: "posts#index")
    end
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

    it 'headers' do
      headers = resource.cors_headers
      expect(headers["access-control-allow-origin"]).to eq "*"
      expect(headers["access-control-allow-credentials"]).to eq "true"
      expect(headers["access-control-allow-methods"]).to eq "DELETE,GET,HEAD,OPTIONS,PATCH,POST,PUT"
      expect(headers["access-control-allow-headers"]).to eq "Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,X-Amz-User-Agent"

      response_parameters = resource.response_parameters(true)
      # pp response_parameters
      expect(response_parameters).to eq(
        {"method.response.header.access-control-allow-origin"=>true,
         "method.response.header.access-control-allow-credentials"=>true,
         "method.response.header.access-control-allow-methods"=>true,
         "method.response.header.access-control-allow-headers"=>true}
      )

      response_parameters = resource.response_parameters(false)
      # pp response_parameters
      expect(response_parameters).to eq(
        {"method.response.header.access-control-allow-origin"=>"'*'",
         "method.response.header.access-control-allow-credentials"=>"'true'",
         "method.response.header.access-control-allow-methods"=>"'DELETE,GET,HEAD,OPTIONS,PATCH,POST,PUT'",
         "method.response.header.access-control-allow-headers"=>"'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,X-Amz-User-Agent'"}
      )
    end
  end

  context "authorization" do
    let(:route) do
      Jets::Route.new(path: "posts/:id", method: :get, to: "posts#show", authorization_type: 'AWS_IAM')
    end
    it "can specify an authorization type" do
      expect(resource.properties["AuthorizationType"]).to eq 'AWS_IAM'
    end
  end
end

