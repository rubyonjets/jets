require_relative "../../../spec_helper"

describe Lam::Build::LambdaDeducer do
  let(:deducer) do
    Lam::Build::LambdaDeducer.new("app/controllers/posts_controller.rb")
  end

  describe "LambdaDeducer" do
    it "deduces lambda js info" do
      deducer.run
      expect(deducer.handlers).to eq([
        {
          handler: "handlers/controllers/posts.create",
          js_path: "handlers/controllers/posts.js",
          js_method: "create"
        }
      ])
    end
  end
end
