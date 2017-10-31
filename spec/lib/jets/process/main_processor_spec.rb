require "spec_helper"

describe Jets::Process::MainProcessor do
  before(:all) do
    @event = { "we" => "love", "using" => "Lambda" }
    @context = {"test" => "1"}
  end
  let(:processor) do
    Jets::Process::MainProcessor.new(
      JSON.dump(@event),
      JSON.dump(@context),
      'handlers/controllers/posts.create' # handler
    )
  end

  describe "MainProcessor" do
    it "find public_instance_methods" do
      processor.run
      expect(processor.event).to eq(@event)
    end
  end
end
