describe Jets::Shim::Adapter::Apigw do
  let :adapter do
    described_class.new(event)
  end

  describe "apigw" do
    let :event do
      JSON.load(IO.read("spec/fixtures/shim/events/apigw.json"))
    end

    it "transforms event to rack env" do
      env = adapter.to_rack_env
      expect(env["REQUEST_METHOD"]).to eq "POST"
      expect(env["PATH_INFO"]).to eq "/path/to/resource"
      expect(env["QUERY_STRING"]).to eq "foo=bar"

      expect(env["HTTP_HOST"]).to eq "1234567890.execute-api.us-east-1.amazonaws.com"
    end
  end

  # Note: I tested it and content-length is not available in apigw event
  # See: https://stackoverflow.com/questions/56693981/how-do-i-get-http-header-content-length-in-api-gateway-lambda-proxy-integratio
  describe "content-type" do
    let :event do
      # curl -H "Content-Type: application/json" => produces this:
      {
        "headers" => {
          "content-type" => "application/json"
        }
      }
    end

    it "should set CONTENT_TYPE" do
      env = adapter.to_rack_env
      expect(env["CONTENT_TYPE"]).to eq "application/json"
      expect(env["HTTP_CONTENT_TYPE"]).to be nil
    end
  end

  describe "request-uri" do
    let :event do
      {
        "path" => "/path/to/resource",
        "queryStringParameters" => {
          "foo" => "bar"
        }
      }
    end

    it "should set REQUEST_URI" do
      env = adapter.to_rack_env
      expect(env["REQUEST_URI"]).to eq "/path/to/resource?foo=bar"
    end
  end
end
