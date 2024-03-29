class RescuableController < Jets::Controller::Base
  rescue_from StandardError, with: :error_handler

  def index
    raise StandardError
  end

  private

  def error_handler
    render json: { error: "there was an error" }, status: 500
  end
end

describe Jets::Controller::Base do
  context RescuableController do
    before(:each) { silence_loggers! }
    after(:each)  { restore_loggers! }

    let(:controller) do
      RescuableController.new({}, nil, :index, {})
    end

    it "rescue_handlers includes error_handler only" do
      expect(controller.class.rescue_handlers).to eq [["StandardError", :error_handler]]
    end

    it "rescues the error raised in index" do
      response = controller.dispatch!
      expect(response[0]).to eq 500
      expect(response[2].first).to eq({error: "there was an error"}.to_json)
    end
  end
end
