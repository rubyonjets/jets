require_relative "../../../spec_helper"

describe Jets::Build::LambdaDeducer do
  let(:deducer) do
    Jets::Build::LambdaDeducer.new("app/controllers/posts_controller.rb")
  end

  describe "LambdaDeducer" do
    it "deduces lambda js info" do
      expect(deducer.class_name).to eq("PostsController")
      expect(deducer.functions).to eq([:create, :update])
    end
  end
end
