require_relative "../../../spec_helper"

describe Lam::Build::LambdaDeducer do
  let(:deducer) do
    Lam::Build::LambdaDeducer.new("app/controllers/posts_controller.rb")
  end

  describe "LambdaDeducer" do
    it "deduces lambda js info" do
      expect(deducer.class_name).to eq("PostsController")
      expect(deducer.functions).to eq([:create, :update])
    end
  end
end

