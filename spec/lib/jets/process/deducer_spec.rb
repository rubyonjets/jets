require "spec_helper"

describe "Deducer" do
  let(:deducer) do
    Jets::Process::Deducer.new("handlers/controllers/posts.create")
  end

  it "find the delegate klass" do
    expect(deducer.delegate_class).to eq Jets::Process::Deducer::ControllerDeducer
  end
end
