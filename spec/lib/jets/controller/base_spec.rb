require "spec_helper"

class FakeController < Jets::Controller::Base
  layout :application

  def handler1; end
  def handler2; end
end

describe Jets::Controller::Base do
  let(:controller) { FakeController.new(event, context, meth) }
  let(:context) { nil }
  let(:meth) { "index" }

  context "general" do
    let(:event) { nil }
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
    let(:event) { json_file("spec/fixtures/events/aws_proxy/request.json") }

    it "#render returns AWS_PROXY compatiable response format" do
      resp = controller.send(:render, json: {"my": "data"})
      # Example of AWS_PROXY compatiable response format
      # {
      #   "statusCode": 200,
      #   "body": "must be a string, even if it is json, it should be a string"
      # }
      expect(resp).to be_a(Hash)
      expect(resp.keys).to include("statusCode")
      expect(resp.keys).to include("body")
      expect(resp["statusCode"]).to eq 200
      expect(resp["body"]).to be_a(String)
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
      resp = controller.send(:render, json: {"my": "data"})
      expect(resp["headers"].keys).to include("Access-Control-Allow-Origin")
      expect(resp["headers"].keys).to include("Access-Control-Allow-Credentials")
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

  context "redirect from localhost" do
    let(:event) do
      {
        "headers" => {
          "origin" => "http://localhost:8888",
        },
      }
    end
    it "redirect_to" do
      resp = controller.send(:redirect_to, "/myurl", status: 301)
      redirect_url = resp["headers"]["Location"]
      expect(redirect_url).to eq "http://localhost:8888/myurl"
    end
  end

  context "redirect from amazonaws.com" do
    let(:event) do
      {
        "headers" => {
          "origin" => "https://nol1n8ho0j.execute-api.us-east-1.amazonaws.com",
        },
      }
    end
    it "redirect_to adds the stage name to the url" do
      resp = controller.send(:redirect_to, "/myurl", status: 301)
      redirect_url = resp["headers"]["Location"]
      expect(redirect_url).to eq "https://nol1n8ho0j.execute-api.us-east-1.amazonaws.com/test/myurl"
    end
  end

  def json_file(path)
    JSON.load(IO.read(path))
  end
end
