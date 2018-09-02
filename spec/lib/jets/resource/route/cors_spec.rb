describe Jets::Resource::Route::Cors do
  let(:cors) { Jets::Resource::Route::Cors.new(task, resource_attributes) }
  let(:resource_attributes) do
    Jets::Resource::Route::Attributes.new(data, task)
  end
  let(:task) do
    task = double(:task).as_null_object
    allow(task).to receive(:meth).and_return(:index)
    task
  end
  let(:data) do
    {
      "{namespace}ApiGatewayResource": {
        type: "AWS::ApiGateway::Method",
        properties: {
          http_method: "GET",
          request_parameters: {},
          resource_id: "!Ref PostsApiGatewayResource",
          rest_api_id: "!Ref RestApi",
          authorization_type: "NONE",
          integration: {
            integration_http_method: "POST",
            type: "AWS_PROXY",
            uri: "!Sub arn:aws:apigateway:${AWS::Region}:lambda:path/2015-03-31/functions/${PostsControllerIndexLambdaFunction.Arn}/invocations",
          },
          method_responses: [],
        }
      }
    }
  end

  context "raw cloudformation definition attributes" do
    it "attributes" do
      attributes = cors.attributes # attributes
      # the class shows up as the fake double class, which is fine for the spec
      expect(attributes.logical_id).to eq "#[Double :task]IndexCorsApiGatewayMethod"
      properties = attributes.properties
      # pp properties # uncomment to debug
      expect(properties["HttpMethod"]).to eq "OPTIONS"
    end
  end
end

