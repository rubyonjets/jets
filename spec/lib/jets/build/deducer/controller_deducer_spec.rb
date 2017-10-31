require "spec_helper"

describe "ControllerDeducer" do
  let(:deducer) do
    Jets::Build::Deducer::ControllerDeducer.new("app/controllers/posts_controller.rb")
  end

  it "deduces info for node shim" do
    expect(deducer.class_name).to eq("PostsController")
    expect(deducer.process_type).to eq("controller")
    expect(deducer.handler_for(:create)).to eq "handlers/controllers/posts.create"
    expect(deducer.js_path).to eq "handlers/controllers/posts.js"
    expect(deducer.cfn_path).to include("posts-controller.yml")

    expect(deducer.functions).to eq(
      [:create, :update, :index, :show, :edit, :delete].sort)
  end
end
