require_relative "../../../spec_helper"

describe Jets::Process::ControllerProcessor do
  before(:all) do
    @event = { "we" => "love", "using" => "Jetsbda" }
    @context = {"test" => "1"}
  end
  let(:processor) do
    Jets::Process::ControllerProcessor.new(
      JSON.dump(@event),
      JSON.dump(@context),
      'handlers/controllers/posts.create' # handler
    )
  end

  describe "ControllerProcessor" do
    it "find public_instance_methods" do
      processor.run
      expect(processor.event).to eq(@event)
    end
  end
end
