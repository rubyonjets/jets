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

    # Would be nice to be able to automate testing the shim
    # context "node shim" do
    #   it "posts create should return json" do
    #     # build.build
    #     # Dir.chdir(ENV["PROJECT_ROOT"]) do
    #       out = execute("cd #{ENV["PROJECT_ROOT"]} && node handlers/controllers/posts.js")
    #       puts out
    #     # end
    #   end
    # end
  end
end

