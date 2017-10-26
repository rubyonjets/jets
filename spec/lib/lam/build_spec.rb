require "spec_helper"

describe Lam::Build do
  before(:each) do
    FileUtils.rm_f("spec/fixtures/project/handlers/controllers/posts.js")
  end
  let(:build) do
    Lam::Build.new(noop: true)
  end

  describe "Build" do
    it "#controller_paths" do
      expect(build.controller_paths).to eq(["app/controllers/posts_controller.rb"])
    end

    it "builds handlers javascript files" do
      build.build
      file_exist = File.exist?("#{Lam.root}handlers/controllers/posts.js")
      expect(file_exist).to be true
    end
  end
end

