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
    let(:context) {"" }
  end

  context "normal lambda proxy integration request for api gateway" do
  end
end
