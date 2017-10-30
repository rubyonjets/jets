require_relative "../../../../spec_helper"

describe "ControllerDeducer" do
  let(:deducer) do
    Jets::Process::Deducer::ControllerDeducer.new("handlers/controllers/posts.create")
  end

  it "deduces path and code" do
    expect(deducer.path).to include("app/controllers/posts_controller.rb")
    expect(deducer.code).to eq "PostsController.new(event, context).create"
  end
end
