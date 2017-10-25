require "spec_helper"

describe Lam::Build do
  before(:each) do
    FileUtils.rm_f("spec/fixtures/project/handlers/controllers/posts.js")
  end
  let(:build) do
    Lam::Build.new({})
  end

  describe "Build" do
    it "#handlers" do
      expect(build.handlers).to eq([
        {
          handler: "handlers/controllers/posts.create",
          js_path: "handlers/controllers/posts.js",
          js_method: "create"
        }
      ])
    end

    it "builds handlers javascript files" do
      build.build
      file_exist = File.exist?("#{Lam.root}handlers/controllers/posts.js")
      expect(file_exist).to be true
    end
  end
end

