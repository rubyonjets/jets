describe Jets::Resource::ApiGateway::RestApi do
  let(:rest_api) { Jets::Resource::ApiGateway::RestApi.new(definition) }

  context "raw cloudformation definition" do
    let(:definition) do
      {
        "RestApi": {
          type: "AWS::ApiGateway::RestApi",
          properties: {
            name: Jets::Naming.gateway_api_name
          }
        }
      }
    end

    it "rest_api" do
      # pp rest_api  # uncomment to see and debug
      expect(rest_api.logical_id).to eq "RestApi"
      expect(rest_api.type).to eq "AWS::ApiGateway::RestApi"
      properties = rest_api.properties
      expect(properties['Name']).to eq Jets::Naming.gateway_api_name
    end
  end
end

