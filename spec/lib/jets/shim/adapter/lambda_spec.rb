describe Jets::Shim::Adapter::Lambda do
  let :adapter do
    described_class.new(event)
  end
  describe "lambda" do
    let :event do
      JSON.load(IO.read("spec/fixtures/shim/events/lambda.json"))
    end

    it "transforms event to rack env" do
      env = adapter.to_rack_env
      expect(env["REQUEST_METHOD"]).to eq "GET"
      expect(env["PATH_INFO"]).to eq "/path/to/resource"
      expect(env["QUERY_STRING"]).to eq "foo=bar"
    end
  end

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

  # APIGW does not provide content-length :( see apigw_spec.rb
  # But Lambda URL does :)
  describe "content-length" do
    let :event do
      # curl -H "Content-Type: application/json" => produces this:
      {
        "headers" => {
          "content-length" => "9"
        }
      }
    end

    it "should set CONTENT_LENGTH" do
      env = adapter.to_rack_env
      expect(env["CONTENT_LENGTH"]).to eq "9"
      expect(env["HTTP_CONTENT_LENGTH"]).to be nil
    end
  end

  describe "request-uri" do
    let :event do
      {
        "version" => "2.0",
        "rawPath" => "/posts",
        "rawQueryString" => "foo=bar"
      }
    end

    it "should set REQUEST_URI" do
      env = adapter.to_rack_env
      expect(env["REQUEST_URI"]).to eq "/posts?foo=bar"
    end
  end

  describe "cookies" do
    let :event do
      {
        "version" => "2.0",
        "rawPath" => "/posts",
        "cookies" => [
          "yummy1=value1",
          "yummy2=value2"
        ]
      }
    end

    it "should set REQUEST_URI" do
      env = adapter.to_rack_env
      expect(env["HTTP_COOKIE"]).to eq "yummy1=value1; yummy2=value2"
    end
  end
end
