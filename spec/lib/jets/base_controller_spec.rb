require "spec_helper"

# For testing lambda_function_names
class FakeController < Jets::BaseController
  def handler1; end
  def handler2; end
end

describe Jets::BaseController do
  let(:controller) { FakeController.new(event, context) }

  context "general" do
    let(:event) { nil }
    let(:context) { nil }
    it "#lambda_functions returns public user-defined methods" do
      expect(controller.lambda_functions).to eq(
        [:handler1, :handler2]
      )
    end
  end

  context "normal lambda function integration request" do
    let(:event) { {"key1" => "value1", "key2" => "value2"} }
    let(:context) { {} }
  end

  context "AWS_PROXY lambda proxy integration request from api gateway" do
    let(:event) { json_file("spec/fixtures/events/aws_proxy/request.json") }
    let(:context) { {} }

    it "#render returns AWS_PROXY compatiable response format" do
      resp = controller.send(:render, json: {"my": "data"})
      # Example of AWS_PROXY compatiable response format
      # {
      #   "statusCode": 200,
      #   "body": "must be a string, even if it is json, it should be a string"
      # }
      expect(resp).to be_a(Hash)
      expect(resp.keys).to include(:statusCode)
      expect(resp.keys).to include(:body)
      expect(resp[:statusCode]).to eq 200
      expect(resp[:body]).to be_a(String)
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
      expect(resp[:headers].keys).to include("Access-Control-Allow-Origin")
      expect(resp[:headers].keys).to include("Access-Control-Allow-Credentials")
    end
  end

  def json_file(path)
    JSON.load(IO.read(path))
  end
end
