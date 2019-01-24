class TestSimpleController < Jets::Controller::Base
  layout :application

  def handler1; end
  def handler2; end
end

describe Jets::Controller::Base do
  let(:controller) { TestSimpleController.new(event, context, meth) }
  let(:context) { nil }
  let(:meth) { "index" }

  context "general" do
    let(:event) { {} }
    it "lambda_functions returns public user-defined methods" do
      expect(controller.lambda_functions).to eq(
        [:handler1, :handler2]
      )
    end

    it "layout set to application" do
      expect(controller.class.layout).to eq "application"
    end
  end

  context "normal lambda function integration request" do
    let(:event) { {"key1" => "value1", "key2" => "value2"} }
  end

  context "AWS_PROXY lambda proxy integration request from api gateway" do
    let(:event) { json_file("spec/fixtures/dumps/api_gateway/request.json") }

    it "#render returns rack triplet" do
      status, headers, body = controller.send(:render, json: {"my": "data"})
      expect(status).to eq "200"
      expect(headers).to be_a(Hash)
      expect(body).to respond_to(:each)
    end

    # Spec is to help understand the AWS_PROXY request format and
    # help document out important elements.
    it "expects AWS_PROXY request format" do
      event = controller.event
      # Example of AWS_PROXY compatiable request format
      # {
      #   "statusCode": 200,
      #   "body": "must be a string, even if it is json, it should be a string"
      # }
      expect(event["resource"]).to eq "/posts"
      expect(event["path"]).to eq "/posts"
      expect(event["httpMethod"]).to eq "POST"
      expect(event["headers"]).to be_a(Hash)
      expect(event["queryStringParameters"]).to be_a(Hash) # or nil
      expect(event["pathParameters"]).to eq nil # or Hash
      expect(event["stageVariables"]).to eq nil # or Hash
      expect(event["requestContext"]).to be_a(Hash)
      expect(event["body"]).to be_a(String)
      expect(event["isBase64Encoded"]).to eq false
    end

    it "adds cors headers" do
      status, headers, body = controller.send(:render, json: {"my": "data"})
      expect(headers.keys).to include("Access-Control-Allow-Origin")
      expect(headers.keys).to include("Access-Control-Allow-Credentials")
    end
  end

  context "json passed in body" do
    let(:event) do
      {
        "queryStringParameters" => {"qs-key" => "qs-value"},
        "pathParameters" => {"path-key" => "path-value"},
        "body" => "{\"body-key1\": \"body-value1\", \"body-key2\": \"body-value2\"}"
      }
    end
    it "params merges all types of parameters together" do
      params = controller.send(:params)
      expect(params.keys.sort).to eq(%w[qs-key path-key body-key1 body-key2].sort)
    end
  end

  context "invalid json passed in body" do
    let(:event) do
      {
        "body" => "{\"body-key1mm.,,, \"body-key2\": \"body-value2\"}"
      }
    end
    it "not error" do
      params = controller.send(:params)
      expect(params.keys).to eq([])
    end
  end

  context "post data from form with content-type application/x-www-form-urlencoded" do
    let(:meth) { "create" }
    let(:event) do
      {
        "headers" => {
          "content-type" => "application/x-www-form-urlencoded",
        },
        "body" => "article%5Btitle%5D=test1&article%5Bbody%5D=test2&article%5Bpublished%5D=yes&commit=Submit"
      }
    end
    it "parse application/x-www-form-urlencoded form data" do
      params = controller.send(:params)
      expect(params).to eq({
        "article" => {
          "title" => "test1",
          "body" => "test2",
          "published" => "yes"
        },
        "commit" => "Submit"
      })
    end
  end

  context "stores" do
    let(:meth) { "index" }
    let(:event) { json_file("spec/fixtures/dumps/api_gateway/stores/index.json") }

    it "headers" do
      controller.set_header("Custom", "MyHeader")
      expect(controller.response.headers).to eq("Custom" => "MyHeader")
    end

    it "process headers" do
      resp = StoresController.process(event, {}, :index)
      expect(resp["headers"]["Set-Cookie"]).to eq "foo=bar"
    end
  end

  context "posts index" do
    let(:meth) { "index" }
    let(:event) { json_file("spec/fixtures/dumps/api_gateway/posts/index.json") }

    it "new adapter" do
      resp = PostsController.process(event, {}, :index)
      expect(resp['statusCode']).to eq "200"
      expect(resp['headers']).to include('X-Runtime') # confirm going through full middleware stack
      # expect(body.read).to eq "whatever"
      expect(resp['headers']['x-jets-base64']).to eq "no"
    end
  end
end
