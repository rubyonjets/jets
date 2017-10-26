require "spec_helper"

# For testing lambda_function_names
class FakeController < Jets::BaseController
  def handler1; end
  def handler2; end
end

describe Jets::BaseController do
  describe "lambda_functions" do
    it "should only list public user defined methods" do
      controller = FakeController.new(nil, nil)
      expect(controller.lambda_functions).to eq(
        [:handler1, :handler2]
      )
    end
  end
end
