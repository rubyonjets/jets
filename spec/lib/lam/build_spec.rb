require "spec_helper"

describe Lam::Build do
  let(:build) do
    Lam::Build.new({})
  end

  describe "Build" do
    it "finds handlers info" do
      expect(build.handlers).to eq([
        {
          handler: "handlers/controllers/posts.create",
          js_path: "handlers/controllers/posts.js",
          js_method: "create"
        }
      ])
    end
  end
end
