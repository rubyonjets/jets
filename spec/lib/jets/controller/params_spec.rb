require "spec_helper"

describe Jets::Controller::Params do
  let(:controller) {
    controller = PostsController.new(event, nil, "update")
    controller.new
    controller
  }

  context "update action called" do
    let(:event) do
      {
        "headers" => {
          "content-type" => "application/x-www-form-urlencoded; charset=UTF-8"
        },
        "body" => "name=John&location=Boston"
      }
    end
    it "params" do
      params = controller.send(:params)
      expect(params.keys).to include("name")
    end
  end
end
